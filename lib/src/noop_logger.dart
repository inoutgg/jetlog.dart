import 'package:jetlog/src/field.dart' show Field;
import 'package:jetlog/src/filter.dart';
import 'package:jetlog/src/handler.dart';
import 'package:jetlog/src/level.dart';
import 'package:jetlog/src/logger.dart';
import 'package:jetlog/src/interface.dart';
import 'package:jetlog/src/tracer.dart';

class NoopTracer implements Tracer {
  @override
  @pragma('vm:prefer-inline')
  void stop(String message) {}
}

class NoopLogger with LoggerBase {
  NoopLogger([this.name]);

  @override
  Level level;

  @override
  final String name;

  @override
  @pragma('vm:prefer-inline')
  Interface bind([Iterable<Field> fields]) => NoopLogger();

  @override
  set handler(Handler handler) {
    /* noop */
  }

  @override
  set filter(Filter handler) {
    /* noop */
  }

  @override
  @pragma('vm:prefer-inline')
  void debug(String message) {
    /* noop */
  }

  @override
  @pragma('vm:prefer-inline')
  Tracer trace(String message, [Level level = Level.debug]) => NoopTracer();

  @override
  @pragma('vm:prefer-inline')
  void info(String message) {
    /* noop */
  }

  @override
  @pragma('vm:prefer-inline')
  void warning(String message) {
    /* noop */
  }

  @override
  @pragma('vm:prefer-inline')
  void danger(String message) {
    /* noop */
  }

  @override
  @pragma('vm:prefer-inline')
  void fatal(String message) {
    /* noop */
  }

  @override
  @pragma('vm:prefer-inline')
  void log(Level level, String message) {
    /* noop */
  }

  @override
  String toString() {
    final buffer = StringBuffer();

    buffer.write('NoopLogger(');

    if (name != null) {
      buffer..write('name=')..write(name)..write(', ');
    }

    buffer..write('level=')..write(level.name)..write(')');

    return buffer.toString();
  }
}
