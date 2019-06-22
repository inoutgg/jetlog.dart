import 'package:structlog/src/field.dart' show Field;
import 'package:structlog/src/level.dart';
import 'package:structlog/src/logger.dart';

/// A single record emitted by a [Logger].
abstract class Record {
  /// Severity level of this record.
  Level get level;

  /// A message.
  String get message;

  /// Name of the logger this record originally emitted by.
  ///
  /// If the logger has no name, may be omitted.
  String get name;

  /// Time when this record was created.
  DateTime get timestamp;

  /// A set of fields bound to the logging context.
  ///
  /// May be omitted if no fields are bound to the logging context.
  Iterable<Field> get fields;
}
