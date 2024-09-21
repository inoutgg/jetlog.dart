import 'package:jetlog/src/field.dart' show Field;
import 'package:jetlog/src/filter.dart';
import 'package:jetlog/src/handler.dart';
import 'package:jetlog/src/interface.dart';
import 'package:jetlog/src/level.dart';
import 'package:jetlog/src/logger.dart';
import 'package:jetlog/src/timer.dart';

final class NoopTimer implements Timer {
  @override
  @pragma('vm:prefer-inline')
  void stop(String message, {Level? level, Iterable<Field>? fields}) {}
}

final class NoopLogger with LoggerBase {
  NoopLogger([this.name]);

  Level? _level;

  static final NoopLogger _logger = NoopLogger();
  static final NoopTimer _timer = NoopTimer();

  @override
  set level(Level? level) {
    _level = level;
  }

  @override
  Level get level => _level ?? Level.info;

  @override
  final String? name;

  @override
  @pragma('vm:prefer-inline')
  Interface withFields([Iterable<Field>? fields]) => _logger;

  @override
  set handler(Handler? handler) {
    // noop
  }

  @override
  set filter(Filter? handler) {
    // noop
  }

  @override
  Timer startTimer(String message, {Level level = Level.debug}) => _timer;

  @override
  void log(Level level, String message) {
    // noop
  }

  @override
  String toString() {
    final buffer = StringBuffer();

    buffer.write('NoopLogger(');

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
