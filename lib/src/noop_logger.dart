import 'package:jetlog/src/field.dart' show Field;
import 'package:jetlog/src/filter.dart';
import 'package:jetlog/src/handler.dart';
import 'package:jetlog/src/level.dart';
import 'package:jetlog/src/logger.dart';
import 'package:jetlog/src/interface.dart';
import 'package:jetlog/src/tracer.dart';

class NoopTracer implements Tracer {
  @override
  void stop(String message) {}
}

class NoopLazyContext implements LazyInterface {
  @override
  void danger(String Function() message) {
    /* noop */
  }

  @override
  void debug(String Function() message) {
    /* noop */
  }

  @override
  void fatal(String Function() message) {
    /* noop */
  }

  @override
  void info(String Function() message) {
    /* noop */
  }

  @override
  void log(Level level, String Function() message) {
    /* noop */
  }

  @override
  Tracer trace(String Function() message) => NoopTracer();

  @override
  void warning(String Function() message) {}
}

class NoopLogger with LoggerBase {
  NoopLogger([this.name]);

  @override
  Level level;

  @override
  final String name;

  @override
  LazyInterface get lazy => NoopLazyContext();

  @override
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
  void debug(String message) {
    /* noop */
  }

  @override
  Tracer trace(String message) => NoopTracer();

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
