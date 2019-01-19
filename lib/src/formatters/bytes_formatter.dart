import 'package:structlog/structlog.dart' show Record;

import 'package:structlog/src/formatters/formatter.dart';

class BytesFormatter extends Formatter<List<int>> {
  BytesFormatter(this._formatter);

  final Formatter<String> _formatter;

  @override
  List<int> format(Record record) => _formatter.format(record).codeUnits;
}
