import 'package:meta/meta.dart' show required;
import 'package:jetlog/src/field.dart';
import 'package:jetlog/src/level.dart';
import 'package:jetlog/src/record.dart';

class RecordImpl implements Record {
  const RecordImpl(
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
