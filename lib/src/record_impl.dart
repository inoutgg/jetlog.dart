import 'package:meta/meta.dart' show required;
import 'package:structlog/src/field.dart';
import 'package:structlog/src/level.dart';
import 'package:structlog/src/record.dart';

class RecordImpl implements Record {
  RecordImpl(
      {@required this.level,
      @required this.timestamp,
      @required this.message,
      this.fields,
      this.name});

  @override
  final Level level;

  @override
  final String message;

  @override
  final String name;

  @override
  final DateTime timestamp;

  @override
  final Iterable<Field> fields;
}
