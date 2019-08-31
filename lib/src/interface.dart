import 'package:jetlog/src/field.dart' show Field;
import 'package:jetlog/src/level.dart';
import 'package:jetlog/src/logger.dart';
import 'package:jetlog/src/tracer.dart' show Tracer;

/// [Interface] represents a common interface that is implemented by both
/// [Logger] and logging context returned by [Interface.bind].
abstract class Interface {
  /// Emits a record with [message] and [level] severity level.
  ///
  /// If [level] is either [Level.all] or [Level.off] it will immediately
  /// throw [ArgumentError].
  void log(Level level, String message);

  /// Emits a record with [message] and [Level.debug] severity level.
  void debug(String message);

  /// Starts tracing and emits a record with [message] and [Level.trace]
  /// severity level; to stop tracing call [Tracer.stop] on the returned tracer.
  Tracer trace(String message);

  /// Emits a record with [message] and [Level.info] severity level.
  void info(String message);

  /// Emits a record with [message] and [Level.warning] severity level.
  void warning(String message);

  /// Emits a record with [message] and [Level.danger] severity level.
  void danger(String message);

  /// Emits a record with [message] and [Level.fatal] severity level.
  void fatal(String message);

  /// Creates and returns a new logging context with bound collection of [fields]
  /// added to existing one.
  Interface bind([Iterable<Field> fields]);
}
