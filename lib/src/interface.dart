import 'package:jetlog/src/field.dart' show Field;
import 'package:jetlog/src/level.dart';
import 'package:jetlog/src/logger.dart';
import 'package:jetlog/src/tracer.dart' show Tracer;

/// [LazyInterface] is collection of methods identical to to those exposed
/// by [Interface], but designed to be evaluated lazily on use.
///
/// Evaluation of messages are postponed until use in a logger. Such
/// behavior is useful when constructing heavy messages (e.g. with interpolation)
/// or fields context, especially when logging such messages in only level e.g.
/// [Level.debug] or [Level.info], etc.
abstract class LazyInterface {
  /// Same as [Interface.log] but evaluates [message] lazily.
  void log(Level level, String Function() message);

  /// Same as [Interface.debug] but evaluates [message] lazily.
  void debug(String Function() message);

  /// Same as [Interface.trace] but evaluates [message] lazily.
  Tracer trace(String Function() message);

  /// Same as [Interface.info] but evaluates [message] lazily.
  void info(String Function() message);

  /// Same as [Interface.warning] but evaluates [message] lazily.
  void warning(String Function() message);

  /// Same as [Interface.danger] but evaluates [message] lazily.
  void danger(String Function() message);

  /// Same as [Interface.fatal] but evaluates [message] lazily.
  void fatal(String Function() message);

  /// Same as [Interface.bind] but evaluates [fields] binding context lazily.
  Interface bind([Iterable<Field> Function() fields]);
}

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

  /// Creates and returns a new logging context with bound collection of
  /// [fields] added to existing one.
  Interface bind([Iterable<Field> fields]);

  /// Returns a [LazyInterface] used to evaluate logs context lazily.
  LazyInterface get lazy;
}
