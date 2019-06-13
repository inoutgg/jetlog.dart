import 'package:structlog/src/field.dart' show Field;
import 'package:structlog/src/filter.dart';
import 'package:structlog/src/handler.dart';
import 'package:structlog/src/level.dart';
import 'package:structlog/src/logger.dart';
import 'package:structlog/src/interface.dart';
import 'package:structlog/src/record.dart';
import 'package:structlog/src/tracer.dart';

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
  void addFilter(Filter filter) {
    /* noop */
  }

  @override
  void removeFilter(Filter filter) {
    /* noop */
  }

  @override
  void clearFilters() {
    /* noop */
  }

  @override
  set handler(Handler handler) {
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
  bool filter(Record record) => false;

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
