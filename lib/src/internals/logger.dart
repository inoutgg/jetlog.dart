import 'dart:async' show Stream, StreamController;

import 'package:structlog/src/field.dart' show Field;
import 'package:structlog/src/filter.dart';
import 'package:structlog/src/handler.dart';
import 'package:structlog/src/interface.dart';
import 'package:structlog/src/internals/logger_context.dart';
import 'package:structlog/src/level.dart';
import 'package:structlog/src/logger.dart';
import 'package:structlog/src/record.dart';
import 'package:structlog/src/tracer.dart';

class LoggerImpl extends Filterer implements Logger {
  LoggerImpl([this.name])
      : _handlers = Set(),
        _stream = StreamController.broadcast(),
        // TODO: set `children` to `null` when logger is detached.
        children = Set() {
    _context = LoggerContext(this);
  }

  final StreamController<Record> _stream;
  final Set<Handler> _handlers;
  LoggerContext _context;
  Level _level;

  Stream<Record> get _onRecord => _stream.stream;

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
      _stream.add(record);

      if (parent != null) parent.add(record);
    }
  }

  @override
  void addHandler(Handler handler) {
    if (_handlers.contains(handler)) {
      throw HandlerRegisterError('Handler is already added!');
    }

    handler.subscription =
        _onRecord.listen(handler.handle, onDone: handler.close);

    _handlers.add(handler);
  }

  @override
  bool isEnabledFor(Level level) {
    if (level == Level.off || level == Level.all) {
      throw ArgumentError.value(
          level,
          'Illegal record\'s severity level! '
          'The use of `Level.off` and `Level.all` is prohibited.');
    }

    ArgumentError.checkNotNull(level, 'level');

    return this.level <= level;
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
    final builder = StringBuffer();

    builder
      ..write('<Logger ')
      ..write('name=')
      ..write(name)
      ..write(', ')
      ..write('level=')
      ..write(level.name)
      ..write('>');

    return builder.toString();
  }
}
