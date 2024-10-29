import 'package:strlog/handlers.dart' show MultiHandler;
import 'package:strlog/src/filter.dart';
import 'package:strlog/src/handler.dart';
import 'package:strlog/src/interface.dart';
import 'package:strlog/src/level.dart';
import 'package:strlog/src/logger_impl.dart';
import 'package:strlog/src/logger_manager.dart';
import 'package:strlog/src/noop_logger.dart';

final _root = LoggerImpl.managed('ROOT_LOGGER');
final _loggers = LoggerManager(_root);

/// [Logger] is used to emit logging messages.
///
/// There are three types of [Logger]:
/// 1. Hierarchical logger: Named logger using dot-separated namespaces.
/// 2. Detached logger: Optionally named logger not part of any logger hierarchy.
/// 3. Noop logger: Logger that does nothing.
///
/// Obtain [Logger] objects using:
/// - [Logger.getLogger]: Returns a hierarchical logger (creates or retrieves existing).
/// - [Logger.detached]: Always returns a new logger, useful for short-lived loggers.
/// - [Logger.noop]: Returns a no-operation logger.
///
/// Each logger has:
/// - A severity level ([Logger.level]) defining the minimum severity it handles.
/// - An optional filter ([Logger.filter]) to further refine which messages are logged.
///
/// Use [Logger.log] or its derivatives ([Logger.debug], [Logger.info], etc.) to log messages.
/// The logger checks:
/// 1. Severity level
/// 2. Filter (if any)
/// 3. Delegates to the registered handler (if any, see [Logger.handler])
///
/// Use [Logger.withFields] to bind structured data to the logging context.
abstract interface class Logger implements Interface {
  /// Creates a new detached logger.
  ///
  /// This logger has no parent or children and is not part of the logger hierarchy.
  /// Useful for short-lived loggers that can be garbage collected.
  factory Logger.detached([String? name]) => LoggerImpl.detached(name);

  /// Creates a new noop logger which never emits logs or delegates records to handlers.
  factory Logger.noop() => NoopLogger();

  /// Retrieves or creates a logger with the given [name].
  ///
  /// Returns an existing logger if one exists, otherwise creates a new one.
  /// The returned logger inherits its [Logger.level] from its parent.
  factory Logger.getLogger(String name) => _loggers.get(name);

  /// The root logger, representing the topmost logger in the hierarchy.
  ///
  /// Its default severity level is [Level.info].
  static Logger get root => _root;

  /// Name of this logger.
  String? get name;

  /// Sets the minimum severity level of [Record]s this logger handles.
  ///
  /// Only records with severity level equal to or higher than [level] will be emitted.
  set level(Level? level);

  /// Gets the minimum severity level of [Record]s this logger handles.
  Level get level;

  /// Sets this logger's handler.
  ///
  /// New loggers have no handler, so logs are discarded until one is set.
  /// Use [MultiHandler] for multiple handlers.
  /// Set to `null` to remove the handler and close any existing event stream.
  set handler(Handler? handler);

  /// Sets this logger's filter.
  ///
  /// New loggers have no filter. Use [MultiFilter] for multiple filters.
  /// Set to `null` to remove the filter.
  set filter(Filter? handler);

  /// Checks if a record with the given severity [level] will be emitted by this logger.
  bool isEnabledFor(Level level);
}

/// Base mixin for implementing [Logger].
///
/// Provides default implementations for common methods across loggers.
base mixin LoggerBase implements Logger {
  @override
  @pragma('vm:prefer-inline')
  bool isEnabledFor(Level level) {
    if (level == Level.off || level == Level.all) {
      throw ArgumentError.value(
          level,
          'Invalid record severity level. '
          'The use of `Level.off` and `Level.all` is not allowed for this method.');
    }

    return this.level <= level;
  }
}
