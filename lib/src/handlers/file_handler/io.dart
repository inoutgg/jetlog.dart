import 'dart:typed_data' show Uint8List;

import 'package:file/file.dart'
    show File, FileMode, FileSystem, FileSystemEntityType, IOSink;
import 'package:file/local.dart' show LocalFileSystem;
import 'package:path/path.dart'
    show extension, basenameWithoutExtension, normalize, dirname, join;
import 'package:strlog/formatters.dart' show Formatter;
import 'package:strlog/strlog.dart' show Handler, Record, Filter;
import 'package:strlog/src/handlers/file_handler/policy.dart';
import 'package:strlog/src/handlers/file_handler/defaults.dart' as defaults;

const _localFs = LocalFileSystem();

class _LogFileStat implements LogFileStat {
  _LogFileStat({required this.firstChanged, required this.size});

  @override
  DateTime firstChanged;

  @override
  int size;
}

/// [FileHandler] writes log records to a file with rotation capabilities.
///
/// The handler performs most file system operations (creation, rotation, cleanup)
/// synchronously, while writes to the file are buffered and processed asynchronously.
///
/// The handler supports log file rotation based on a provided [LogFileRotationPolicy]
/// and can maintain a maximum number of backup files. When rotation occurs, the current
/// log file is archived with a timestamp and a new file is created.
class FileHandler extends Handler {
  FileHandler(
    this._policy, {
    required Formatter formatter,
    required String path,
    FileSystem? fs,
    int? maxBackupsCount,
  })  : assert(path != ""),
        _formatter = formatter,
        _fs = fs ?? _localFs,
        _maxBackupsCount = maxBackupsCount ?? defaults.maxBackupCount,
        _isClosed = false,
        _path = _ParsedPath.fromString(path) {
    _open();
  }

  final LogFileRotationPolicy _policy;
  final Formatter _formatter;
  final int _maxBackupsCount;
  Filter? _filter;

  bool _isClosed;

  final FileSystem _fs;
  final _ParsedPath _path;
  late File _file; // created in _open
  late IOSink _sink; // created in _open
  late _LogFileStat _stat; // created in _open

  /// Sets records filter.
  ///
  /// Set filter behaves the same way as a [Logger] filter.
  set filter(Filter? filter) => _filter = filter;

  /// Returns a stat about the managed logging file.
  LogFileStat get stat => _stat;

  /// Opens a log file in append-only mode.
  ///
  /// If the opened file is ready for rotation it will be rotate
  /// before returning control.
  void _open() {
    _file = _fs.file(_path._path);
    final stat = _file.statSync();
    switch (stat.type) {
      case FileSystemEntityType.file:
        {
          final nextStat =
              _LogFileStat(size: stat.size, firstChanged: stat.changed);
          if (_policy.shouldRotate(nextStat)) {
            _rotate();
          } else {
            _stat = nextStat;
          }
        }
        break;

      case FileSystemEntityType.notFound:
        _file.createSync(recursive: true);
        _stat = _LogFileStat(size: 0, firstChanged: DateTime.now());
        break;

      default:
        throw StateError('The file entity type ${stat.type} is not supported.');
    }

    _sink = _file.openWrite(mode: FileMode.append);
  }

  /// [_gc] performs garbage collection on old backup files.
  void _gc() {
    final dir = _fs.directory(_path._dirname);
    final files = List.of(dir
        .listSync(followLinks: false)
        .where((file) => file.statSync().type == FileSystemEntityType.file));

    if (files.length > _maxBackupsCount) {
      files.sort((a, b) => _ParsedPath.fromString(a.path)
          .compareTo(_ParsedPath.fromString(b.path)));

      final backupsToDelete = files.length - _maxBackupsCount;
      for (var i = 0; i < backupsToDelete; i++) {
        files[i].deleteSync();
      }
    }
  }

  /// [_move] renames the current log file by appending a timestamp tag to its name.
  ///
  /// This is called during log file rotation to archive the current log file
  /// before starting a new one.
  void _move() => _file.renameSync(_path.taggedPath());

  /// Performs a log file rotation by moving the current file to a backup copy,
  /// cleaning up old backup files if needed, and opening a new log file.
  void _rotate() {
    _move();
    _gc();
    _open();
  }

  /// [_write] writes bytes to the file.
  ///
  /// The method checks if rotation is needed based on the current file stats and policy.
  /// If rotation is needed, it rotates the file before writing the new bytes.
  /// After writing, it updates the file stats with the new size and modification time.
  void _write(Uint8List bytes) {
    if (_policy.shouldRotate(_stat)) {
      _rotate();
    }

    _sink.add(bytes);
    _stat.size += bytes.lengthInBytes;
  }

  /// Closes the file handler and underlying file sink.
  ///
  /// This method ensures that all buffered data is written to disk by calling
  /// [IOSink.flush] before closing it. If the handler is already closed,
  /// this method returns immediately.
  @override
  Future<void> close() async {
    if (_isClosed) {
      return;
    }

    _isClosed = true;
    await super.close();
    await _sink.flush();
    await _sink.close();
  }

  @override
  void handle(Record record) {
    final filter = _filter;
    final shouldFilter = filter != null && !filter(record);
    if (shouldFilter) {
      return;
    }

    _write(Uint8List.fromList(_formatter(record)));
  }
}

/// _ParsedPath represents a parsed file system path with its components.
class _ParsedPath implements Comparable<_ParsedPath> {
  const _ParsedPath._(
      this._path, this._dirname, this._basename, this._tag, this._extension);

  /// Creates a [_ParsedPath] instance from the provided file system path string.
  ///
  /// The path is normalized and parsed into its components: dirname, basename,
  /// and extension.
  factory _ParsedPath.fromString(String path) {
    final normalizedPath = normalize(path);

    final baseName = basenameWithoutExtension(normalizedPath);
    final tagIndex = baseName.lastIndexOf('_');
    String tag = '';
    late final String finalBaseName;
    if (tagIndex != -1) {
      tag = baseName.substring(tagIndex + 1);
      finalBaseName = baseName.substring(0, tagIndex);
    } else {
      finalBaseName = baseName;
    }
    return _ParsedPath._(normalizedPath, dirname(normalizedPath), finalBaseName,
        tag, extension(normalizedPath));
  }

  /// Returns formatted path with timestamp tag.
  ///
  /// Creates a path string appending a timestamp tag in YYYYMMDDHHMMSS format
  /// between the base filename and extension.
  String taggedPath() {
    final now = DateTime.now();
    final year = now.year.toString().padLeft(4, '0');
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final second = now.second.toString().padLeft(2, '0');
    final tag = '$year$month$day$hour$minute$second';
    return join(_dirname, '${_basename}_$tag$_extension');
  }

  final String _path;
  final String _dirname;
  final String _basename;
  final String _extension;
  final String _tag;

  @override
  int compareTo(_ParsedPath other) {
    final baseNameComparison = _basename.compareTo(other._basename);
    if (baseNameComparison != 0) {
      return baseNameComparison;
    }
    return _tag.compareTo(other._tag);
  }
}
