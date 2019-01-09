import 'package:structlog/src/field.dart' show FieldSet;
import 'package:structlog/src/level.dart';
import 'package:structlog/src/logger.dart';

/// An error thrown if specified [Record.level] is either [Level.all] or
/// [Level.off].
class RecordLevelError extends Error {
  RecordLevelError(this.message);

  /// This error message.
  final String message;
}

/// A single record emitted by a [Logger].
abstract class Record {
  /// Severity level of this record.
  Level get level;

  /// A message.
  String get message;

  /// Name of the logger this record originally emitted by.
  String get name;

  /// Time when this record was created.
  DateTime get time;

  /// A set of fields bound to the logging context.
  FieldSet get fields;
}
