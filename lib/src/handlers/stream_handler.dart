import 'dart:async' show StreamSink;

import 'package:meta/meta.dart' show required;
import 'package:jetlog/jetlog.dart' show Handler, Record, Filter;
import 'package:jetlog/formatters.dart' show Formatter;

/// [StreamHandler] delegates log records downstream.
///
/// Each log record is formatted using the `formatter` before
/// submitting it to the downstream.
class StreamHandler extends Handler {
  StreamHandler(this._stream, {@required Formatter formatter})
      : _formatter = formatter {
    ArgumentError.checkNotNull(_stream, 'stream');
    ArgumentError.checkNotNull(formatter, 'formatter');
  }

  final Formatter _formatter;
  final StreamSink<List<int>> _stream;
  Filter _filter;

  /// Sets records filterer.
  ///
  /// Set filterer behaves the same way as a [Logger] filter.
  set filter(Filter filter) => _filter = filter;

  @override
  void handle(Record record) {
    if (_filter != null && !_filter.filter(record)) {
      return;
    }

    _stream.add(_formatter(record));
  }
}
