import 'package:strlog/src/field.dart';
import 'package:strlog/src/level.dart';
import 'package:strlog/src/record.dart';
import 'package:meta/meta.dart' show immutable;

@immutable
class RecordImpl implements Record {
  const RecordImpl(
      {required this.level,
      required this.timestamp,
      required this.message,
      this.fields,
      this.name});

  @override
  final Level level;

  @override
  final String message;

  @override
  final String? name;

  @override
  final DateTime timestamp;

  @override
  final Iterable<Field>? fields;
}
