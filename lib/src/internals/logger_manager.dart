import 'package:structlog/src/internals/logger.dart';

class LoggerManager {
  LoggerManager(this.root) : _loggers = {};

  final Map<String, LoggerImpl> _loggers;
  final LoggerImpl root;

  LoggerImpl get(String name) {
    if (name.startsWith('.')) {
      throw ArgumentError.value(
          name, 'Logger name must not start with a `.\'!');
    }

    LoggerImpl logger;

    if (_loggers.containsKey(name)) {
      logger = _loggers[name];
    } else {
      logger = LoggerImpl(name);
      _loggers[name] = logger;
    }

    final lastIndexOfDot = name.lastIndexOf('.');
    final parent = lastIndexOfDot.isNegative
        ? root
        : get(name.substring(0, lastIndexOfDot));

    logger.level = parent.level;
    logger.parent = parent;
    parent.children.add(logger);

    return logger;
  }
}
