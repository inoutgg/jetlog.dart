import 'package:jetlog/src/field.dart';
import 'package:jetlog/src/interface.dart';
import 'package:jetlog/src/level.dart';

/// [DefaultLog] defines [Interface.log] aliases on [Interface] for some predefined [Level]s.
extension DefaultLog on Interface {
  /// Emits a record with [message] and [Level.debug] severity level.
  @pragma('vm:prefer-inline')
  void debug(String message, [Iterable<Field>? fields]) =>
      log(Level.debug, message, fields);

  /// Emits a record with [message] and [Level.info] severity level.
  @pragma('vm:prefer-inline')
  void info(String message, [Iterable<Field>? fields]) =>
      log(Level.info, message, fields);

  /// Emits a record with [message] and [Level.warn] severity level.
  @pragma('vm:prefer-inline')
  void warn(String message, [Iterable<Field>? fields]) =>
      log(Level.warn, message, fields);

  /// Emits a record with [message] and [Level.error] severity level.
  @pragma('vm:prefer-inline')
  void error(String message, [Iterable<Field>? fields]) =>
      log(Level.error, message, fields);

  /// Emits a record with [message] and [Level.fatal] severity level.
  @pragma('vm:prefer-inline')
  void fatal(String message, [Iterable<Field>? fields]) =>
      log(Level.fatal, message, fields);
}
