import 'package:jetlog/src/field.dart' show Field;
import 'package:jetlog/src/level.dart';
import 'package:jetlog/src/logger.dart';
import 'package:jetlog/src/timer.dart';

/// [Interface] represents a set of common methods that is implemented by both
/// [Logger] and logging context returned by [Interface.withFields].
abstract interface class Interface {
  /// Emits a record with [message] and [level] severity level.
  ///
  /// If [level] is either [Level.all] or [Level.off] it will immediately
  /// throw [ArgumentError].
  void log(Level level, String message);

  /// Starts tracing and emits a record with [message] and [level]
  /// severity level; to stop tracing call [Timer.stop] on the returned timer.
  Timer startTimer(String message, {Level level = Level.debug});

  /// Creates and returns a new logging context with bound collection of
  /// [fields] added to existing ones.
  ///
  /// Example:
  /// ```dart
  /// final context = logger.withFields({
  ///   Str('username', 'roman-vanesyan'),
  ///   Str('filename', 'avatar.png'),
  ///   Str('mime', 'image/png'),
  /// });
  ///
  /// final timer = context.startTimer('Uploading!', Level.info);
  ///
  /// // Emulate uploading, wait for 1 sec.
  /// await Future<void>.delayed(const Duration(seconds: 1));
  ///
  /// timer.stop('Aborting...');
  /// context.fatal('Failed to upload!');
  /// ```
  ///
  /// It is possible to extend bound context with another fields.
  ///
  /// Example:
  /// ```dart
  /// var context = logger.bind({Str('first', '1st'}); // => { "first": "1st" }
  /// context = context.bind({Str('second', '2nd'}); // => { "first": "1st", "second": "2nd" }
  /// ```
  Interface withFields([Iterable<Field>? fields]);
}
