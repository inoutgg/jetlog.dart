import 'package:structlog/src/filter.dart';
import 'package:structlog/src/handler.dart';
import 'package:structlog/src/level.dart';
import 'package:structlog/src/interface.dart';
import 'package:structlog/src/internals/logger.dart';

abstract class Logger implements Filterer, Interface {
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

  /// Retrieves this logger severity level.
  Level get level;

  /// Tests whether record with severity [level] will be emitted by this logger.
  bool isEnabledFor(Level level);

  /// Adds a [handler] to this logger.
  void addHandler(Handler handler);
}
