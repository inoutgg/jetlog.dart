import 'dart:async' show FutureOr;
import 'dart:collection' show Queue;
import 'dart:io'
    show
        File,
        FileMode,
        FileSystemEntityType,
        FileSystemException,
        IOSink,
        Platform;
import 'dart:typed_data' show Uint8List;
import 'package:jetlog/formatters.dart' show Formatter;
import 'package:jetlog/jetlog.dart' show Filter;

const int minSize = 1024;
const Duration minInterval = Duration(seconds: 1);

class _State {
  static const int opening = 2;
  static const int rotating = 2 << 1;
  static const int closing = 2 << 2;
  static const int closed = 2 << 3;
}

class Stat {
  const Stat._(
      {required this.size, required this.modified, required this.newSize});

  final int size;
  final int newSize;
  final DateTime modified;
}

abstract class RotationPolicy {
  const factory RotationPolicy.never() = _NeverRotationPolicy;
  const factory RotationPolicy.interval(Duration interval) =
      _IntervalRotationPolicy;
  const factory RotationPolicy.sized(int maxSize) = _SizedRotationPolicy;

  bool shouldRotate(Stat stat);
}

class _NeverRotationPolicy implements RotationPolicy {
  const _NeverRotationPolicy();

  @override
  bool shouldRotate(_) => false;
}

class _SizedRotationPolicy implements RotationPolicy {
  const _SizedRotationPolicy(this.maxSize) : assert(maxSize >= minSize);

  final int maxSize;

  @override
  bool shouldRotate(Stat stat) => stat.size > 0 && stat.newSize > maxSize;
}

class _IntervalRotationPolicy implements RotationPolicy {
  const _IntervalRotationPolicy(this.interval)
      : assert(interval >= minInterval);

  final Duration interval;

  @override
  bool shouldRotate(Stat stat) {
    final now = DateTime.now();
    final diff = now.difference(stat.modified);

    return interval.inMilliseconds - diff.inMilliseconds < 0;
  }
}

typedef Rotator = FutureOr<void> Function(String src, String dest);

FutureOr<void> rotator(String src, String dest) async {
  final srcFile = File(src);

  try {
    await srcFile.rename(dest);
  } on FileSystemException {
    // If failed to rename file, try to move it.
    await srcFile.copy(dest);
    await srcFile.delete();
  }
}

class FileHandler extends Handler {
  FileHandler(this._uri,
      {required Formatter formatter,
      RotationPolicy rotationPolicy = const RotationPolicy.never(),
      Rotator rotator = rotator,
      bool compress = false,
      int maxBackUps = 0})
      : _rotationPolicy = rotationPolicy,
        _rotator = rotator,
        _queue = Queue(),
        _compress = compress,
        _maxBackUps = maxBackUps,
        _formatter = formatter,
        _state = 0 {
    _processFileName();
    _open();
  }

  Filter? _filter;
  final Formatter _formatter;
  final RotationPolicy _rotationPolicy;
  final Rotator _rotator;
  final bool _compress;
  final int _maxBackUps;

  // File path.
  final Uri _uri;
  List<String> _dirnameSegments;
  String _basename;

  final Queue<Uint8List> _queue;
  File _file;
  IOSink _sink;
  int _state;

  // Internal states tracking info about current size of log file,
  // and date at which it was last updated.
  DateTime _modified;
  int _size;

  Stat get stat => Stat._(
        size: _size,
        modified: _modified,
      );
  set filter(Filter filter) => _filter = filter;

  void _processFileName() {
    final segments = _uri.pathSegments;
    _dirnameSegments = _uri.pathSegments.sublist(0, segments.length - 1);
    _basename = _uri.pathSegments.last;
  }

  String _getFilePath(int index) => Uri(pathSegments: [
        ..._dirnameSegments,
        '$_basename.$index${_compress ? '.gz' : ''}'
      ]).toFilePath(windows: Platform.isWindows);

  Future<void> _rollover() async {
    // Sequentially rename backup files from the tail.
    for (int i = _maxBackUps - 1; i > 0; i--) {
      final curPath = _getFilePath(i);

      if (File(curPath).existsSync()) {
        final nextPath = _getFilePath(i + 1);
        final nextFile = File(nextPath);

        // Remove backup file with index bigger than allowed.
        if (nextFile.existsSync()) {
          await nextFile.delete();
        }

        await _rotator(curPath, nextPath);
      }
    }

    final backupPath = _getFilePath(1);
    final backupFile = File(backupPath);
    if (backupFile.existsSync()) {
      await backupFile.delete();
    }

    await _rotator(_file.path, backupPath);
  }

  Future<void> _open({bool newly = false}) async {
    if (_state & _State.opening > 0) {
      return;
    }

    _state |= _State.opening;
    _file = File.fromUri(_uri);

    final fileStat = _file.statSync();
    switch (fileStat.type) {
      case FileSystemEntityType.file:
        _modified = fileStat.modified;
        _size = fileStat.size;

        // Checks whether we need to rotate file.
        if (newly ||
            _shouldRotate(
                Stat._(size: _size, modified: _modified, newSize: 0))) {
          await _rollover();

          _modified = DateTime.now();
          _size = 0;
        }
        break;

      case FileSystemEntityType.notFound:
        await _file.create(recursive: true);
        _modified = DateTime.now();
        _size = 0;
        break;

      case FileSystemEntityType.directory:
      case FileSystemEntityType.link:
        throw StateError('Race condition');
    }

    _sink = _file.openWrite(mode: FileMode.writeOnlyAppend);
    _state ^= _State.opening;
  }

  Future<void> _rotate() async {
    if (_state & _State.rotating > 0) {
      throw StateError('Logging file is already been rotated!');
    }

    _state |= _State.rotating;

    await _close();
    await _open(newly: true);

    _state ^= _State.rotating;

    // Process pending messages.
    _processQueue();
  }

  bool _shouldRotate(Stat stat) =>
      _maxBackUps > 0 && _rotationPolicy.shouldRotate(stat);

  void _processQueue() {
    if (_state & _State.opening | _state & _State.rotating > 0) {
      return;
    }

    while (_queue.isNotEmpty) {
      final bytes = _queue.first;
      final size = _size + bytes.lengthInBytes;
      final newStat = Stat._(size: _size, newSize: size, modified: _modified);

      if (_shouldRotate(newStat)) {
        _rotate();
        break;
      }

      _sink.add(bytes);
      _queue.removeFirst();
      _size = size;
      _modified = DateTime.now();
    }
  }

  Future<void> _close() async {
    await _sink.flush();
    await _sink.close();
  }

  FutureOr<void> rotate() => _rotate();

  @override
  void handle(Record record) {
    if (_state & _State.closed > 0) {
      throw StateError('The file handler has been closed!');
    }

    // Do not accept a new message if file is closing.
    if (_state & _State.closing > 0) {
      return;
    }

    if (!(_filter?.call(record) ?? true)) {
      return;
    }

    final bytes = Uint8List.fromList(_formatter(record));
    _queue.add(bytes);

    // Process queued messages.
    _processQueue();
  }

  @override
  Future<void> close() async {
    _state = _State.closing;

    // Closing underlying sink to prevent new logs.
    await super.close();

    if (_queue.isNotEmpty) {
      _processQueue();
    }

    await _close();
    _state = _State.closed;
  }
}
