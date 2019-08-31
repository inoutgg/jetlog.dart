import 'dart:async' show StreamController;

import 'package:jetlog/src/field.dart' show Field;
import 'package:jetlog/src/filter.dart';
import 'package:jetlog/src/handler.dart';
import 'package:jetlog/src/interface.dart';
import 'package:jetlog/src/logging_context.dart';
import 'package:jetlog/src/level.dart';
import 'package:jetlog/src/logger.dart';
import 'package:jetlog/src/record.dart';
import 'package:jetlog/src/tracer.dart';

class LoggerImpl with LoggerBase {
  LoggerImpl._(this.name, [this.children]) {
    _context = LoggingContext(this);
  }

  factory LoggerImpl.detached([String name]) => LoggerImpl._(name);

  factory LoggerImpl.managed([String name]) => LoggerImpl._(name, {});

  StreamController<Record> _controller;
  Filter _filter;
  LoggingContext _context;
  Level _level;

  final Set<LoggerImpl> children;
  LoggerImpl parent;

  @override
  final String name;

  @override
  LazyInterface get lazy => _context.lazy;

  @override
  set level(Level level) => _level = level;

  @override
  Level get level {
    if (_level != null) return _level;
    if (parent != null) return parent.level;

    // Defaults to `Level.info`.
    return Level.info;
  }

  @override
  set handler(Handler handler) {
    _controller?.close();

    if (handler != null) {
      _controller = StreamController();
      handler.subscription =
          _controller.stream.listen(handler.handle, onDone: handler.close);
    }
  }

  @override
  set filter(Filter filter) => _filter = filter;

  void add(Record record) {
    if (isEnabledFor(record.level)) {
      if (_filter != null && !_filter.call(record)) {
        return;
      }

      _controller?.add(record);

      if (parent != null) parent.add(record);
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
