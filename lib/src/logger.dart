import 'package:structlog/handlers.dart' show MultiHandler;
import 'package:structlog/src/filter.dart';
import 'package:structlog/src/handler.dart';
import 'package:structlog/src/interface.dart';
import 'package:structlog/src/logger_impl.dart';
import 'package:structlog/src/logger_manager.dart';
import 'package:structlog/src/noop_logger.dart';
import 'package:structlog/src/level.dart';

final _root = LoggerImpl.managed('ROOT_LOGGER');
final _loggers = LoggerManager(_root);

abstract class Logger implements Filterer, Interface {
  /// Creates a new logger.
  ///
  /// Created logger has no parent and any children and is not a part of
  /// the logger hierarchy.
  ///
  /// Typically, this should be used if short-living logger is necessary,
  /// which may be GC'ed later.
  factory Logger.detached([String name]) => LoggerImpl.detached(name);

  /// Creates a new noop logger, it never writes out any logs and never
  /// delegates records to handlers.
  factory Logger.noop([String name]) => NoopLoggerImpl(name);

  /// Retrieves a logger with [name]. If the logger already exists, then it will
  /// be returned, otherwise a new logger is created.
  ///
  /// Returned logger inherits [Logger.level] of it's parent.
  factory Logger.getLogger(String name) => _loggers.get(name);

  /// The root logger represents a topmost logger in loggers hierarchy.
  ///
  /// The severity level of the root logger is default to [Level.info].
  static Logger get root => _root;

  /// Name of this logger.
  String get name;

  /// Sets a minimum severity level of a [Record] to be emitted by this logger.
  ///
  /// Only records with severity level equal to or higher then
  /// (in terms of [Level.value]) the [level] may be emitted by this logger;
  /// for example, if [level] set to [Level.info], only records with severity
  /// level equal to [Level.info], [Level.warning], [Level.danger],
  /// or [Level.fatal] will be emitted by this logger.
  set level(Level level);

  /// Sets this logger logs handler.
  ///
  /// No handlers are register for a freshly created logger and any records
  /// that are emitted using the logger are discarded, unless handler is set.
  ///
  /// To define multiple handlers for a logger use [MultiHandler].
  ///
  /// If provided value is `null`, previously created event stream is closed
  /// if any.
  set handler(Handler handler);

  /// Retrieves this logger severity level.
  Level get level;

  /// Tests whether record with severity [level] will be emitted by this logger.
  bool isEnabledFor(Level level);
}
