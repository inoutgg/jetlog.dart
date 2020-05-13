import 'package:jetlog/src/interface.dart';
import 'package:jetlog/src/level.dart';
import 'package:jetlog/src/tracer.dart' show Tracer;
import 'package:jetlog/src/tracer_impl.dart' show TracerImpl;

/// [TraceLog] defines a trace method on [Interface].
extension TraceLog on Interface {
  /// Starts tracing and emits a record with [message] and [level]
  /// severity level; to stop tracing call [Tracer.stop] on the returned tracer.
  @pragma('vm:prefer-inline')
  Tracer trace(String message, [Level level = Level.debug]) =>
      TracerImpl(this, level)..start(message);
}

/// [DefaultLog] defines [Interface.log] aliases on [Interface] for some predefined [Level]s.
extension DefaultLog on Interface {
  /// Emits a record with [message] and [Level.debug] severity level.
  @pragma('vm:prefer-inline')
  void debug(String message) => log(Level.debug, message);

  /// Emits a record with [message] and [Level.info] severity level.
  @pragma('vm:prefer-inline')
  void info(String message) => log(Level.info, message);

  /// Emits a record with [message] and [Level.warning] severity level.
  @pragma('vm:prefer-inline')
  void warning(String message) => log(Level.warning, message);

  /// Emits a record with [message] and [Level.danger] severity level.
  @pragma('vm:prefer-inline')
  void danger(String message) => log(Level.danger, message);

  /// Emits a record with [message] and [Level.fatal] severity level.
  @pragma('vm:prefer-inline')
  void fatal(String message) => log(Level.fatal, message);
}
