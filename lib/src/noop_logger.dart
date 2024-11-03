import 'package:strlog/src/field.dart' show Field;
import 'package:strlog/src/filter.dart';
import 'package:strlog/src/handler.dart';
import 'package:strlog/src/interface.dart';
import 'package:strlog/src/level.dart';
import 'package:strlog/src/logger.dart';
import 'package:strlog/src/timer.dart';

final class NoopTimer implements Timer {
  @override
  @pragma('vm:prefer-inline')
  void stop(String message, {Level? level, Iterable<Field>? fields}) {}
}

final class NoopLogger with LoggerBase {
  factory NoopLogger() => _logger;
  NoopLogger._();

  Level? _level;

  static final NoopLogger _logger = NoopLogger._();
  static final NoopTimer _timer = NoopTimer();

  @override
  set level(Level? level) {
    _level = level;
  }

  @override
  Level get level => _level ?? Level.info;

  @override
  String? get name => null;

  @override
  @pragma('vm:prefer-inline')
  Interface withFields([Iterable<Field>? fields]) => _logger;

  @override
  set handler(Handler? handler) {/* noop */}

  @override
  set filter(Filter? handler) {/* noop */}

  @override
  Timer startTimer(String message, {Level level = Level.debug}) => _timer;

  @override
  void log(Level level, String message, [Iterable<Field>? fields]) {/* noop */}

  @override
  String toString() {
    final buffer = StringBuffer();

    buffer.write('NoopLogger(');

    buffer
      ..write('level=')
      ..write(level.name)
      ..write(')');

    return buffer.toString();
  }
}
