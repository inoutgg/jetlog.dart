import 'dart:io' show BytesBuilder;
import 'dart:typed_data' show Uint8List;

import 'package:file/file.dart' show File, FileSystem, IOSink;
import 'package:file/local.dart' show LocalFileSystem;
import 'package:strlog/formatters.dart' show Formatter;
import 'package:strlog/strlog.dart' show Handler, Record, Filter;

import './policy.dart';

const _localFs = LocalFileSystem();

// [FileHandler] writes log records to the file via [fs].
class FileHandler extends Handler {
  FileHandler(this._policy, {required Formatter formatter, FileSystem? fs})
      : _formatter = formatter,
        _fs = fs ?? _localFs,
        _buffer = BytesBuilder(copy: false),
        _stateMask = 0;

  final FileRotationPolicy _policy;
  final Formatter _formatter;
  Filter? _filter;

  final FileSystem _fs;
  final BytesBuilder _buffer;
  IOSink? _sink;
  int _stateMask; // controls lifecyrcle of the file

  /// Sets records filter.
  ///
  /// Set filter behaves the same way as a [Logger] filter.
  set filter(Filter? filter) => _filter = filter;

  void _rotate() {}

  void _tick() {
    if (_policy.shouldRotate()) {
      return _rotate();
    }

    while (_buffer.isNotEmpty) {
      final bytes = _buffer.takeBytes();

      _sink?.write(bytes);
    }
  }

  @override
  void handle(Record record) {
    final filter = _filter;
    final shouldFilter = filter != null && !filter(record);
    if (shouldFilter) {
      return;
    }

    _buffer.add(Uint8List.fromList(_formatter(record)));
    _tick();
  }
}
