/// Package library `strlog` provides fast, structured, leveled logger.
///
/// To use this library in your code
///
/// ```dart
/// import 'package:strlog/strlog.dart';
/// ```
///
/// This package exposes the main class [Logger] used to instantiate both
/// detached and hierarchical loggers, [Field] class and its custom
/// extensions for builtin types (e.g. [Bool], [Int], etc.) - elementary
/// blocks for building context bound structured logging entries.
///
/// Example
/// ```dart
/// final logger = Logger.getLogger('strlog.example.hierarchical');
///
/// logger.context({
///   Str('hello', 'world'),
/// }).info('Example');
/// ```
library;

export 'src/default_log.dart';
export 'src/field.dart';
export 'src/filter.dart';
export 'src/handler.dart';
export 'src/interface.dart';
export 'src/level.dart';
export 'src/logger.dart';
export 'src/record.dart';
export 'src/timer.dart';
