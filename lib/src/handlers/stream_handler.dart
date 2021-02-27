import 'dart:async' show StreamSink;

import 'package:jetlog/formatters.dart' show Formatter;
import 'package:jetlog/jetlog.dart' show Handler, Record, Filter;

/// [StreamHandler] delegates log records downstream.
///
/// Each log record is formatted using the `formatter` before
/// submitting it to the downstream.
class StreamHandler extends Handler {
  StreamHandler(this._sink, {required Formatter formatter})
      : _formatter = formatter;

  final Formatter _formatter;
  final StreamSink<List<int>> _sink;
  Filter? _filter;

  /// Sets records filterer.
  ///
  /// Set filterer behaves the same way as a [Logger] filter.
  set filter(Filter? filter) => _filter = filter;

  @override
  void handle(Record record) {
    if (!(_filter?.call(record) ?? true)) {
      return;
    }

    _sink.add(_formatter(record));
  }
}
