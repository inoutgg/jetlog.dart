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
///
/// Even-thought the global logger comes fully configured, it is possible to
/// override it via [set]. It might be particulary useful to specify configured
/// logger once at the main entrypoint and use it as sigleton across the app.
library jetlog.global_logger;

import 'package:jetlog/formatters.dart' show TextFormatter;
import 'package:jetlog/handlers.dart' show ConsoleHandler;
import 'package:jetlog/jetlog.dart';

var _logger = Logger.detached()
  ..level = Level.all
  ..handler = ConsoleHandler(formatter: TextFormatter.withDefaults());

// Sets the global logger to the provided one.
void set(Logger logger) => _logger = logger;

/// Gets the minimum severity level for records emitted by the global logger.
Level get level => _logger.level;

/// Sets the minimum severity level for records emitted by the global logger.
set level(Level level) => _logger.level = level;

/// Sets the handler for the global logger.
set handler(Handler handler) => _logger.handler = handler;

/// Sets the filter for the global logger.
set filter(Filter filter) => _logger.filter = filter;

/// Logs a message with the specified severity level.
void log(Level level, String message, [Iterable<Field>? fields]) =>
    _logger.log(level, message, fields);

/// Logs a debug message.
void debug(String message, [Iterable<Field>? fields]) =>
    _logger.debug(message, fields);

/// Starts a timer and logs a message. Returns a [Timer] object.
///
/// Call [Timer.stop] on the returned object to stop tracing.
Timer startTimer(String message, {Level level = Level.debug}) =>
    _logger.startTimer(message, level: level);

/// Logs an info message.
void info(String message, [Iterable<Field>? fields]) =>
    _logger.info(message, fields);

/// Logs a warn message.
void warn(String message, [Iterable<Field>? fields]) =>
    _logger.warn(message, fields);

/// Logs a error (error) message.
void error(String message, [Iterable<Field>? fields]) =>
    _logger.error(message, fields);

/// Logs a fatal message.
void fatal(String message, [Iterable<Field>? fields]) =>
    _logger.fatal(message, fields);

/// Creates a new logging context with additional fields.
///
/// Returns a new [Interface] with the specified fields added to the existing context.
Interface withFields(Iterable<Field> fields) => _logger.withFields(fields);
