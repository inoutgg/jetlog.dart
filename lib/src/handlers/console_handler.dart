import 'dart:convert' show utf8;

import 'package:jetlog/formatters.dart' show Formatter;
import 'package:jetlog/jetlog.dart' show Filter, Handler, Logger, Record;

/// [ConsoleHandler] prints logging records using built-in [print].
class ConsoleHandler extends Handler {
  ConsoleHandler({required Formatter formatter, Filter? filter})
      : _formatter = formatter,
        _filter = filter;

  final Formatter _formatter;
  Filter? _filter;

  /// Sets records filterer.
  ///
  /// Set filterer behaves the same way as a [Logger] filter.
  set filter(Filter filter) => _filter = filter;

  @override
  void handle(Record record) {
    if (_filter != null && !_filter!(record)) {
      return;
    }

    final message = _formatter(record);

    print(utf8.decode(message).trim());
  }
}
