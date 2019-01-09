import 'package:structlog/src/field.dart' show FieldSetCollector;
import 'package:structlog/src/filter.dart';
import 'package:structlog/src/handler.dart';
import 'package:structlog/src/level.dart';
import 'package:structlog/src/logger.dart';
import 'package:structlog/src/interface.dart';
import 'package:structlog/src/record.dart';
import 'package:structlog/src/tracer.dart';
import 'package:structlog/src/noop_logger/tracer.dart';
import 'package:structlog/src/noop_logger/field.dart';

class NoopLogger implements Logger {
  @override
  Interface bind(void collect(FieldSetCollector collector)) {
    collect(NoopFieldSetCollector());

    return NoopLogger();
  }

  @override
  set level(Level level) {
    /* noop */
  }

  @override
  bool isEnabledFor(Level level) => false;

  @override
  void addFilter(Filter filter) {
    /* noop  */
  }

  @override
  void removeFilter(Filter filter) {
    /* noop  */
  }

  @override
  void addHandler(Handler handler) {
    /* noop  */
  }

  @override
  void debug(String message) {
    /* noop  */
  }

  @override
  Tracer trace(String message) => NoopTracer();

  @override
  void info(String message) {
    /* noop  */
  }

  @override
  void warning(String message) {
    /* noop  */
  }

  @override
  void danger(String message) {
    /* noop  */
  }

  @override
  void fatal(String message) {
    /* noop  */
  }

  @override
  bool filter(Record record) => false;

  @override
  void log(Level level, String message) {
    /* noop  */
  }
}
