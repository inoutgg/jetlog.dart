import 'dart:async' show StreamController;

import 'package:jetlog/src/field.dart' show Field;
import 'package:jetlog/src/filter.dart';
import 'package:jetlog/src/handler.dart';
import 'package:jetlog/src/interface.dart';
import 'package:jetlog/src/level.dart';
import 'package:jetlog/src/logger.dart';
import 'package:jetlog/src/logging_context.dart';
import 'package:jetlog/src/record.dart';
import 'package:jetlog/src/timer.dart';

final class LoggerImpl with LoggerBase {
  LoggerImpl._(this.name, [this.children]) {
    _context = LoggingContext(this);
  }

  factory LoggerImpl.detached([String? name]) => LoggerImpl._(name);

  factory LoggerImpl.managed(String name) => LoggerImpl._(name, {});

  late final LoggingContext _context;
  StreamController<Record>? _controller;
  Filter? _filter;
  Level? _level;

  final Set<LoggerImpl>? children;
  LoggerImpl? parent;

  @override
  final String? name;

  @override
  set level(Level? level) => _level = level;

  @override
  Level get level =>
      // If level is not set and logger is out of hierarchy default to `Level.info`.
      _level ?? parent?.level ?? Level.info;

  @override
  set handler(Handler? handler) {
    _controller?.close();

    if (handler != null) {
      _controller = StreamController();
      handler.subscription =
          _controller!.stream.listen(handler.handle, onDone: handler.close);
    } else {
      _controller = null;
    }
  }

  @override
  set filter(Filter? filter) => _filter = filter;

  void add(Record record) {
    if (isEnabledFor(record.level)) {
      if (_filter != null && !_filter!(record)) {
        return;
      }

      _controller?.add(record);
      parent?.add(record);
    }
  }

  @override
  @pragma('vm:prefer-inline')
  void log(Level level, String message) => _context.log(level, message);

  @override
  Timer startTimer(String message, {Level level = Level.debug}) =>
      _context.startTimer(message, level: level);

  @override
  @pragma('vm:prefer-inline')
  Interface bind([Iterable<Field>? fields]) => _context.bind(fields);

  @override
  String toString() {
    final buffer = StringBuffer();

    buffer.write('Logger(');

    if (name != null) {
      buffer
        ..write('name=')
        ..write(name)
        ..write(', ');
    }

    buffer
      ..write('level=')
      ..write(level.name)
      ..write(')');

    return buffer.toString();
  }
}
