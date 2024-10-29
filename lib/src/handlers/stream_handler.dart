import 'dart:async' show StreamSink;

import 'package:strlog/formatters.dart' show Formatter;
import 'package:strlog/strlog.dart' show Handler, Record, Filter;

/// [StreamHandler] delegates log records downstream.
///
/// Each log record is formatted using the `formatter` before
/// submitting it to the downstream.
class StreamHandler extends Handler {
  StreamHandler(this._sink, {required Formatter formatter})
      : _formatter = formatter;

  final StreamSink<List<int>> _sink;
  final Formatter _formatter;
  Filter? _filter;

  /// Sets records filter.
  ///
  /// Set filter behaves the same way as a [Logger] filter.
  set filter(Filter? filter) => _filter = filter;

  @override
  void handle(Record record) {
    final filter = _filter;
    final shouldFilter = filter != null && !filter(record);
    if (shouldFilter) {
      return;
    }

    _sink.add(_formatter(record));
  }
}
