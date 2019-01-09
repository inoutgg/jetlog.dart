import 'dart:async' show Stream, StreamController;
import 'package:structlog/src/field.dart' show FieldSetCollectorCallback;
import 'package:structlog/src/filter.dart';
import 'package:structlog/src/handler.dart';
import 'package:structlog/src/level.dart';
import 'package:structlog/src/interface.dart';
import 'package:structlog/src/record.dart';
import 'package:structlog/src/tracer.dart';
import 'package:structlog/src/internals/logging_context.dart';
import 'package:structlog/src/logger.dart';

class LoggerImpl extends Filterer implements Logger {
  LoggerImpl([this.name])
      : _level = Level.info,
        _handlers = Set(),
        _stream = StreamController.broadcast() {
    _context = LoggingContext(this);
  }

  factory LoggerImpl.getLogger(String name) {
    final logger = LoggerImpl(name);

    return logger;
  }

  final StreamController<Record> _stream;
  final Set<Handler> _handlers;
  LoggingContext _context;
  Level _level;

  Stream<Record> get _onRecord => _stream.stream;

  @override
  final String name;

  @override
  set level(Level level) => _level = level;

  void add(Record record) {
    _stream.add(record);
  }

  @override
  void addHandler(Handler handler) {
    if (_handlers.contains(handler)) {
      throw HandlerRegisterError(
          'The same instance of a handler was registered for the logger twice!');
    }

    handler.subscription =
        _onRecord.listen(handler.handle, onDone: handler.close);

    _handlers.add(handler);
  }

  @override
  bool isEnabledFor(Level level) {
    if (level == Level.off || level == Level.all) {
      throw RecordLevelError('Illegal record\'s severity level! '
          'The use of `Level.off` and `Level.all` is prohibited.');
    }

    return _level <= level;
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
  Interface bind(FieldSetCollectorCallback collector) =>
      _context.bind(collector);

  @override
  String toString() {
    final builder = StringBuffer();

    builder
      ..write('<Logger')
      ..write(' ')
      ..write('level=')
      ..write(_level)
      ..write(', ')
      ..write('name=')
      ..write(name)
      ..write('>');

    return builder.toString();
  }
}
