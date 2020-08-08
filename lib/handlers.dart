/// This package library provides a set of logging record handlers such as
/// [ConsoleHandler], [MemoryHandler], [StreamHandler], [FileHandler] and
/// [MultiHandler].
///
/// [FileHandler] is only supported targeting Dart VM (including Flutter)
/// and will fail on other platforms.
///
/// To use this library in your code:
/// ```dart
/// import 'package:jetlog/handlers.dart';
/// ```
library jetlog.handlers;

export 'src/handlers/console_handler.dart';
export 'src/handlers/file_handler/noop.dart'
    if (dart.library.io) 'src/handlers/file_handler/io.dart';
export 'src/handlers/memory_handler.dart';
export 'src/handlers/multi_handler.dart';
export 'src/handlers/stream_handler.dart';
