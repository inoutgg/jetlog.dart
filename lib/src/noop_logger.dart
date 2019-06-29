import 'package:jetlog/src/field.dart' show Field;
import 'package:jetlog/src/filter.dart';
import 'package:jetlog/src/handler.dart';
import 'package:jetlog/src/level.dart';
import 'package:jetlog/src/logger.dart';
import 'package:jetlog/src/interface.dart';
import 'package:jetlog/src/tracer.dart';

class NoopTracerImpl implements Tracer {
  @override
  void stop(String message) {}
}

class NoopLoggerImpl with LoggerBase {
  NoopLoggerImpl([this.name]);

  @override
  Level level;

  @override
  final String name;

  @override
  Interface bind([Iterable<Field> fields]) => NoopLoggerImpl();

  @override
  set handler(Handler handler) {
    /* noop */
  }

  @override
  set filter(Filter handler) {
    /* noop */
  }

  @override
  void debug(String message) {
    /* noop */
  }

  @override
  Tracer trace(String message) => NoopTracerImpl();

  @override
  void info(String message) {
    /* noop */
  }

  @override
  void warning(String message) {
    /* noop */
  }

  @override
  void danger(String message) {
    /* noop */
  }

  @override
  void fatal(String message) {
    /* noop */
  }

  @override
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
