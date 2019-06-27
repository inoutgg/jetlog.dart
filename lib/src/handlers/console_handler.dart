import 'dart:convert' show utf8;

import 'package:meta/meta.dart' show required;
import 'package:structlog/structlog.dart' show Filter, Handler, Logger, Record;
import 'package:structlog/formatters.dart' show Formatter;

/// [ConsoleHandler] prints logging records using built-in [print].
class ConsoleHandler extends Handler {
  ConsoleHandler({@required Formatter formatter, Filter filter})
      : _formatter = formatter,
        _filter = filter;

  final Formatter _formatter;
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

    final message = _formatter.call(record);
    final len = message.length;

    print(utf8.decode(message.getRange(0, len - 2).toList(growable: false)));
  }
}
