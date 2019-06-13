import 'dart:async' show StreamController;

import 'package:structlog/src/field.dart' show Field;
import 'package:structlog/src/filter.dart';
import 'package:structlog/src/handler.dart';
import 'package:structlog/src/interface.dart';
import 'package:structlog/src/logging_context.dart';
import 'package:structlog/src/level.dart';
import 'package:structlog/src/logger.dart';
import 'package:structlog/src/record.dart';
import 'package:structlog/src/tracer.dart';

class LoggerImpl with LoggerBase, FiltererBase {
  LoggerImpl._(this.name, [this.children]) {
    _context = LoggingContext(this);
  }

  factory LoggerImpl.detached([String name]) => LoggerImpl._(name);

  factory LoggerImpl.managed([String name]) => LoggerImpl._(name, {});

  StreamController<Record> _controller;
  LoggingContext _context;
  Level _level;

  final Set<LoggerImpl> children;
  LoggerImpl parent;

  @override
  final String name;

  @override
  set level(Level level) => _level = level;

  @override
  Level get level {
    if (_level != null) return _level;
    if (parent != null) return parent.level;

    // Defaults to `Level.info`.
    return Level.info;
  }

  void add(Record record) {
    if (isEnabledFor(record.level) && filter(record)) {
      _controller?.add(record);

      if (parent != null) parent.add(record);
    }
  }

  @override
  set handler(Handler handler) {
    _controller?.close();

    if (handler != null) {
      _controller = StreamController(sync: true);
      handler.subscription =
          _controller.stream.listen(handler.handle, onDone: handler.close);
    }
  }

  @override
  void log(Level level, String message) => _context.log(level, message);

  @override
  void debug(String message) => _context.debug(message);

  @override
  Tracer trace(String message) => _context.trace(message);

  @override
  void info(String message) => _context.info(message);

  @override
  void warning(String message) => _context.warning(message);

  @override
  void danger(String message) => _context.danger(message);

  @override
  void fatal(String message) => _context.fatal(message);

  @override
  Interface bind([Iterable<Field> fields]) => _context.bind(fields);

  @override
  String toString() {
    final buffer = StringBuffer();

    buffer.write('Logger(');

    if (name != null) {
      buffer..write('name=')..write(name)..write(', ');
    }

    buffer..write('level=')..write(level.name)..write(')');

    return buffer.toString();
  }
}
