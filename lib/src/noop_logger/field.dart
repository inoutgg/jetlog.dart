import 'package:structlog/src/field.dart';

class NoopFieldSetCollector implements FieldSetCollector {
  @override
  void add<V>(Field<V> field) { /* noop */ }

  @override
  void addBool(String name, bool value) { /* noop */ }

  @override
  void addDateTime(String name, DateTime value) { /* noop */ }

  @override
  void addDouble(String name, double value) { /* noop */ }

  @override
  void addDuration(String name, Duration value) { /* noop */ }

  @override
  void addInt(String name, int value) { /* noop */ }

  @override
  void addNum(String name, num value) { /* noop */ }

  @override
  void addObject(String name, Loggable value) {
    value.toFieldSet(NoopFieldSetCollector());
  }

  @override
  void addString(String name, String value) { /* noop */ }
}
