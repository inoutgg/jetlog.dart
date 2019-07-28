import 'package:jetlog/handlers.dart' show MultiHandler;
import 'package:jetlog/src/filter.dart';
import 'package:jetlog/src/handler.dart';
import 'package:jetlog/src/interface.dart';
import 'package:jetlog/src/logger_impl.dart';
import 'package:jetlog/src/logger_manager.dart';
import 'package:jetlog/src/noop_logger.dart';
import 'package:jetlog/src/level.dart';

final _root = LoggerImpl.managed('ROOT_LOGGER');
final _loggers = LoggerManager(_root);

/// [Logger] is used to emit logging messages.
///
/// There are three types of [Logger]: hierarchical logger - named logger using a
/// hierarchical dot-separated namespaces and detached logger - optionally named
/// logger that isn't part of any logger hierarchy and noop logger - logger
/// that does nothing.
///
/// [Logger] objects may be obtained by calling [Logger.getLogger],
/// [Logger.detached] or [Logger.noop] factories. [Logger.getLogger] returns a
/// hierarchical logger by either creating it or obtaining existing one.
/// [Logger.detached] always returns a new logger regardless to the provided
/// logger [name], typically such loggers are necessary if short-living logger
/// is needed which may be garbage collected later. [Logger.noop] returns
/// a no operation logger.
///
/// Each logger has a severity level reflecting a minimum severity level of
/// logging message this logger cares about (see [Logger.level]). It's possible
/// to register a logging message filter that filters messages based on various
/// criteria (see [Logger.filter]).
///
/// To log a message use [Logger.log] method or one of its derivatives such
/// [Logger.debug], [Logger.info], etc. On each [Logger.log] calls logger
/// performs a severity level check and discarding those messages which have
/// severity level this logger doesn't cares about; if message passes severity
/// level check it then filtered out by a registered logger filter if any.
/// Those messages which pass both checks delegated to a registered handler if
/// any (see [Logger.handler]).
///
/// To bind structured data to the logging context call [Logger.bind] with
/// data represented as a collection of [Field]s. Calling to [Logger.bind] will
/// result into a new context with logging capabilities and bound collection of
/// fields has been created.
abstract class Logger implements Interface {
  /// Creates a new detached logger.
  ///
  /// Created logger has no parent and children and is not a part of
  /// the logger hierarchy.
  ///
  /// Typically, this factory should be used if short-living logger is necessary,
  /// which may be garbage collected later.
  factory Logger.detached([String name]) => LoggerImpl.detached(name);

  /// Creates a new noop logger which never emits logs and never
  /// delegates records to handlers.
  factory Logger.noop([String name]) => NoopLogger(name);

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

  /// Sets a minimum severity level of a [Record]s this logger cares about.
  ///
  /// Only records with severity level equal to or higher then
  /// (in terms of [Level.value]) the [level] may be emitted by this logger;
  /// for example, if [level] set to [Level.info], only records with severity
  /// level equal to [Level.info], [Level.warning], [Level.danger],
  /// or [Level.fatal] will be emitted by this logger.
  set level(Level level);

  /// Retrieves minimum severity level of [Record]s this logger cares about.
  Level get level;

  /// Sets this logger logs handler.
  ///
  /// No handlers are register for a freshly created logger and any records
  /// that are emitted using the logger are discarded, unless handler is set.
  ///
  /// To define multiple handlers for a logger use [MultiHandler] class.
  ///
  /// If provided value is `null`, previously created event stream is closed
  /// if any.
  set handler(Handler handler);

  /// Set this logger filter.
  ///
  /// No filters are register for a freshly created logger and thus any records
  /// with acceptable severity level are delegated to this logger handler.
  ///
  /// To define multiple filters for a logger use [MultiFilter] class.
  ///
  /// Set to `null` to remove previously set filter if any.
  set filter(Filter handler);

  /// Tests whether record with severity [level] will be emitted by this logger.
  bool isEnabledFor(Level level);
}

/// Base mixin for implementing [Logger].
///
/// Contains default implementations of common methods across loggers.
mixin LoggerBase implements Logger {
  @override
  bool isEnabledFor(Level level) {
    ArgumentError.checkNotNull(level, 'level');

    if (level == Level.off || level == Level.all) {
      throw ArgumentError.value(
          level,
          'Illegal record\'s severity level! '
          'The use of `Level.off` and `Level.all` is prohibited for this method.');
    }

    return this.level <= level;
  }
}
