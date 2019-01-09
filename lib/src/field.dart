import 'package:meta/meta.dart' show required;

typedef FieldSetCollectorCallback = void Function(FieldSetCollector collector);

/// [FieldKind] represents a [Field.value] type. It is used while serializing
/// [Field] to remove necessity to dynamically probe [Field.value] type.
class FieldKind {
  const FieldKind(this.value);

  /// Unique value for type.
  final int value;

  static const boolean = FieldKind(0x1);
  static const string = FieldKind(0x2);
  static const float = FieldKind(0x3);
  static const integer = FieldKind(0x4);
  static const number = FieldKind(0x5);
  static const duration = FieldKind(0x6);
  static const dateTime = FieldKind(0x7);
  static const object = FieldKind(0x8);
  static const any = FieldKind(0x9);
}

/// A [Field] used to add a key-value pair to a logger's context.
class Field<V> {
  const Field({@required this.name, @required this.value, @required this.kind});

  /// Name of this field (a key).
  final String name;

  /// Value of this field.
  final V value;

  /// Kind of field's value, used to determine [Field.value] type without
  /// runtime lookups.
  final FieldKind kind;

  @override
  bool operator ==(Object other) => other is Field && other.value == value;

  @override
  int get hashCode => name.hashCode;
}

/// An immutable set of [Field]s.
abstract class FieldSet implements Iterable<Field<Object>> {}

/// A builder for constructing a set of fields.
abstract class FieldSetCollector {
  /// Adds [field] of type [V] to the fields set.
  void add<V>(Field<V> field);

  /// Adds a field with [name] of type [bool] to the field set.
  // ignore:avoid_positional_boolean_parameters
  void addBool(String name, bool value);

  /// Adds a field with [name] of type [String] to the field set.
  void addString(String name, String value);

  /// Adds a field with [name] of type [double] to the field set.
  void addDouble(String name, double value);

  /// Adds a field with [name] of type [int] to the field set.
  void addInt(String name, int value);

  /// Adds a field with [name] of type [num] to the field set.
  void addNum(String name, num value);

  /// Adds a field with [name] of type [Duration] to the field set.
  void addDuration(String name, Duration value);

  /// Adds a field with [name] of type [DateTime] to the field set.
  void addDateTime(String name, DateTime value);

  /// Adds a field with [name] of custom type (i.e. class that implements
  /// [Loggable]) to the field set.
  void addObject(String name, Loggable value);
}

/// [Loggable] provides the ability to be logged as part of logging context
/// field set.
abstract class Loggable {
  /// Marshals this class to field set.
  void toFieldSet(FieldSetCollector collector);
}
