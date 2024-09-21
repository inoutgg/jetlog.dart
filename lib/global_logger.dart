/// This library provides a global logger for easy logging across your application.
///
/// Usage:
/// ```dart
/// import 'package:jetlog/global_logger.dart';
/// ```
///
/// The global logger is preconfigured with:
/// - Severity level: [Level.debug]
/// - Handler: [ConsoleHandler] with [TextFormatter.defaultFormatter]
library jetlog.global_logger;

import 'package:jetlog/formatters.dart' show TextFormatter;
import 'package:jetlog/handlers.dart' show ConsoleHandler;
import 'package:jetlog/jetlog.dart';

final Logger _logger = Logger.detached()
  ..level = Level.all
  ..handler = ConsoleHandler(formatter: TextFormatter.withDefaults());

/// Gets the minimum severity level for records emitted by the global logger.
Level get level => _logger.level;

/// Sets the minimum severity level for records emitted by the global logger.
set level(Level level) => _logger.level = level;

/// Sets the handler for the global logger.
set handler(Handler handler) => _logger.handler = handler;

/// Sets the filter for the global logger.
set filter(Filter filter) => _logger.filter = filter;

/// Logs a message with the specified severity level.
void log(Level level, String message) => _logger.log(level, message);

/// Logs a debug message.
void debug(String message) => _logger.debug(message);

/// Starts a timer and logs a message. Returns a [Timer] object.
///
/// Call [Timer.stop] on the returned object to stop tracing.
Timer trace(String message, {Level level = Level.debug}) =>
    _logger.startTimer(message, level: level);

/// Logs an info message.
void info(String message) => _logger.info(message);

/// Logs a warning message.
void warning(String message) => _logger.warning(message);

/// Logs a danger (error) message.
void danger(String message) => _logger.danger(message);

/// Logs a fatal message.
void fatal(String message) => _logger.fatal(message);

/// Creates a new logging context with additional fields.
///
/// Returns a new [Interface] with the specified fields added to the existing context.
Interface withFields([Iterable<Field>? fields]) => _logger.withFields(fields);
