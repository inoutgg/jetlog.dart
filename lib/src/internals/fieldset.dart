import 'dart:collection';
import 'package:structlog/src/field.dart';

class FieldSetImpl extends IterableMixin<Field<Object>> implements FieldSet {
  FieldSetImpl() : _fields = Set();

  final Set<Field<Object>> _fields;

  @override
  Iterator<Field<Object>> get iterator => _fields.iterator;

  @override
  String toString() => _fields.toString();

  /// Adds a [field] to the set, if [field] with [Field.name] already been added
  /// to set the field is ignored.
  void add(Field<Object> field) => _fields.add(field);

  /// Adds each field in [fields] to the set.
  void addAll(Iterable<Field<Object>> fields) => _fields.addAll(fields);
}

/// [FieldSetBuilder] represents a build capable to construct (to build) a new
/// [FieldSet] based on accumulated values.
class FieldSetBuilder implements FieldSetCollector {
  FieldSetBuilder() : _fields = FieldSetImpl();

  final FieldSetImpl _fields;

  @override
  void add<V>(Field<V> field) => _fields.add(field);

  @override
  void addBool(String name, bool value) =>
      add<bool>(Field<bool>(name: name, value: value, kind: FieldKind.boolean));

  @override
  void addString(String name, String value) => add<String>(
      Field<String>(name: name, value: value, kind: FieldKind.string));

  @override
  void addDouble(String name, double value) => add<double>(
      Field<double>(name: name, value: value, kind: FieldKind.float));

  @override
  void addInt(String name, int value) =>
      add<int>(Field<int>(name: name, value: value, kind: FieldKind.integer));

  @override
  void addNum(String name, num value) =>
      add<num>(Field<num>(name: name, value: value, kind: FieldKind.number));

  @override
  void addDuration(String name, Duration value) => add<Duration>(
      Field<Duration>(name: name, value: value, kind: FieldKind.duration));

  @override
  void addDateTime(String name, DateTime value) => add<DateTime>(
      Field<DateTime>(name: name, value: value, kind: FieldKind.dateTime));

  @override
  void addObject(String name, Loggable value) {
    final builder = FieldSetBuilder();

    value.toFieldSet(builder);

    add<FieldSet>(Field<FieldSet>(
        name: name, value: builder.build(), kind: FieldKind.object));
  }

  FieldSetImpl build() => _fields;
}
