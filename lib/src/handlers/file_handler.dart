import 'dart:collection' show Queue;
import 'dart:io'
    show
        File,
        FileMode,
        FileSystemEntityType,
        FileSystemException,
        GZipCodec,
        IOSink;
import 'dart:typed_data' show Uint8List;

import 'package:jetlog/formatters.dart' show Formatter;
import 'package:jetlog/jetlog.dart' show Handler, Record;
import 'package:meta/meta.dart' show required;

/// Minimum allowed value of maxSize for [RotationPolicy.sized].
const int minSize = 1024; // 1kb

class _State {
  static const int opening = 2;
  static const int rotating = 2 << 1;
  static const int closing = 2 << 2;
  static const int closed = 2 << 3;
}

/// Logging file current stats.
class Stat {
  const Stat._({@required this.size, @required this.modified});

  /// Logging file size.
  final int size;

  /// Time logging file was last modified at.
  final DateTime modified;
}

abstract class RotationPolicy {
  const factory RotationPolicy.never() = _NeverRotatePolicy;

  const factory RotationPolicy.interval(Duration interval) =
      _IntervalRotatePolicy;

  const factory RotationPolicy.sized({int maxSize}) = _SizedRotatePolicy;

  /// Determines whether logging file should be rotated.
  bool shouldRotate(Stat stat);
}

class _NeverRotatePolicy implements RotationPolicy {
  const _NeverRotatePolicy();

  @override
  bool shouldRotate(_) => false;
}

class _SizedRotatePolicy implements RotationPolicy {
  const _SizedRotatePolicy({
    @required this.maxSize,
  }) : assert(maxSize >= minSize);

  final int maxSize;

  @override
  bool shouldRotate(Stat stat) => stat.size > maxSize;
}

class _IntervalRotatePolicy implements RotationPolicy {
  const _IntervalRotatePolicy(this.interval);

  final Duration interval;

  @override
  bool shouldRotate(Stat stat) {
    final now = DateTime.now();
    final diff = now.difference(stat.modified);

    return interval.inMilliseconds - diff.inMilliseconds < 0;
  }
}

/// [FileHandler] is used to write logging records to specified file.
///
/// An optional rotation policy can be set to set file rotation condition.
/// On rotating file is gotten a logfile index suffix.
class FileHandler extends Handler {
  /// Creates a new [FileHandler] targeting file under given URI.
  ///
  /// An optional [rotationPolicy] can be provided to set rotation conditions.
  /// There available different kinds of rotation policy auto of the box
  /// such as time, size rotation policy, etc. It is also possible to define
  /// custom policy to control rotation.
  ///
  /// If [maxBackUps] is non-zero, at most [maxBackUps] backup files will be
  /// kept.
  ///
  /// If [compress] is set, backup file will be compressed using gzip.
  /// By default compression is off.
  FileHandler(this._uri,
      {@required Formatter formatter,
      RotationPolicy rotationPolicy = const RotationPolicy.never(),
      bool compress = false,
      int maxBackUps = 0})
      : _rotationPolicy = rotationPolicy,
        _queue = Queue(),
        _compress = compress,
        _maxBackUps = maxBackUps,
        _formatter = formatter,
        _state = 0 {
    _processFileName();
    _open();
  }

  final Formatter _formatter;
  final RotationPolicy _rotationPolicy;
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

  /// Returns current logging file stats.
  Stat get stat => Stat._(
        size: _size,
        modified: _modified,
      );

  void _processFileName() {
    final segments = _uri.pathSegments;
    _dirnameSegments = _uri.pathSegments.sublist(0, segments.length - 1);
    _basename = _uri.pathSegments.last;
  }

  String _getFileName(int index) =>
      Uri(pathSegments: [..._dirnameSegments, '$_basename.$index'])
          .toFilePath();

  Future<void> _rollover() async {
    // Sequentially rename backup files from the tail.
    for (int i = _maxBackUps - 1; i > 0; i--) {
      final currentBackUpFileName = _getFileName(i);
      final nextBackUpFileName = _getFileName(i + 1);
      final currentBackUpFile = File(currentBackUpFileName);
      final nextBackUpFile = File(nextBackUpFileName);

      if (currentBackUpFile.existsSync()) {
        // Remove backup file with index bigger than allowed.
        if (nextBackUpFile.existsSync()) {
          await nextBackUpFile.delete();
        }

        if (_compress) {
          final sink = nextBackUpFile.openWrite(mode: FileMode.writeOnly);

          await sink.addStream(
              currentBackUpFile.openRead().transform(GZipCodec().encoder));
          await sink.close();
        } else {
          try {
            await currentBackUpFile.rename(nextBackUpFileName);

            // If failed to rename file, try to move it.
          } on FileSystemException {
            await currentBackUpFile.copy(nextBackUpFileName);
            await currentBackUpFile.delete();
          }
        }
      }
    }

    final backUpFileName = _getFileName(1);
    final backUpFile = File(backUpFileName);
    if (backUpFile.existsSync()) {
      await backUpFile.delete();
    }

    await _file.rename(backUpFileName);
  }

  Future<void> _open({bool newly = false}) async {
    if (_state & _State.opening > 0) {
      throw StateError('Invalid!');
    }

    _state |= _State.opening;
    _file = File.fromUri(_uri);

    final fileStat = _file.statSync();
    switch (fileStat.type) {
      case FileSystemEntityType.file:
        _modified = fileStat.modified;
        _size = fileStat.size;

        // Checks whether we need to rotate file.
        if (newly || _shouldRotate(stat)) {
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
      throw StateError('Invalid!');
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
      final newStat = Stat._(size: size, modified: _modified);

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

  /// Rotates logging file.
  Future<void> rotate() => _rotate();

  @override
  void handle(Record record) {
    if (_state & _State.closed > 0) {
      throw StateError('The file handler has been closed!');
    }

    // Do not accept a new message if we are closing.
    if (_state & _State.closing > 0) {
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
