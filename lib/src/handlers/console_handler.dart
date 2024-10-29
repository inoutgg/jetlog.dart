import 'dart:convert' show utf8;

import 'package:strlog/formatters.dart' show Formatter;
import 'package:strlog/strlog.dart' show Filter, Handler, Logger, Record;

/// [ConsoleHandler] prints log records using built-in [print].
class ConsoleHandler extends Handler {
  ConsoleHandler({required Formatter formatter, Filter? filter})
      : _formatter = formatter,
        _filter = filter;

  final Formatter _formatter;
  Filter? _filter;

  /// Sets records filter.
  ///
  /// Set filter behaves the same way as a [Logger] filter.
  set filter(Filter filter) => _filter = filter;

  @override
  void handle(Record record) {
    final filter = _filter;
    final shouldFilter = filter != null && !filter(record);
    if (shouldFilter) {
      return;
    }

    final message = _formatter(record);

    print(utf8.decode(message).trim());
  }
}
