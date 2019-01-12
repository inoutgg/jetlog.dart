import 'package:meta/meta.dart' show required;
import 'package:structlog/src/field.dart';
import 'package:structlog/src/level.dart';
import 'package:structlog/src/record.dart';

class RecordImpl implements Record {
  RecordImpl(
      {@required this.level,
      @required this.message,
      @required this.fields,
      this.name})
      : time = DateTime.now();

  @override
  final Level level;

  @override
  final String message;

  @override
  final String name;

  @override
  final DateTime time;

  @override
  final Iterable<Field> fields;
}
