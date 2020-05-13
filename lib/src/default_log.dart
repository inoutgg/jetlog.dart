import 'package:jetlog/src/interface.dart';
import 'package:jetlog/src/level.dart';

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
