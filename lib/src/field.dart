import 'package:meta/meta.dart' show required;

/// [FieldKind] represents a [Field.value] type. It is used for [Field]
/// serialization to remove necessity to dynamically probe [Field.value] type.
class FieldKind {
  const FieldKind(this.value);

  /// Unique value for type.
  final int value;

  /// A field kind representing any value type.
  static const FieldKind any = FieldKind(0x1);

  /// A field kind representing [bool] value type.
  static const FieldKind boolean = FieldKind(0x2);

  /// A field kind representing [DateTime] value type.
  static const FieldKind dateTime = FieldKind(0x3);

  /// A field kind representing [double] value type.
  static const FieldKind double = FieldKind(0x4);

  /// A field kind representing [Duration] value type.
  static const FieldKind duration = FieldKind(0x5);

  /// A field kind representing [int] value type.
  static const FieldKind integer = FieldKind(0x6);

  /// A field kind representing [num] value type.
  static const FieldKind number = FieldKind(0x7);

  /// A field kind representing custom value type (a class implementing
  /// [Loggable]).
  static const FieldKind object = FieldKind(0x8);

  /// A field kind representing a [String] value type.
  static const FieldKind string = FieldKind(0x9);
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

/// A field with value of a [Duration] type.
class Dur extends Field<Duration> {
  const Dur(String name, Duration value)
      : super(name: name, value: value, kind: FieldKind.duration);
}

/// A field with value of a [double] type.
class Double extends Field<double> {
  const Double(String name, double value)
      : super(name: name, value: value, kind: FieldKind.double);
}

/// A field with value of [num] type.
class Num extends Field<num> {
  const Num(String name, num value)
      : super(name: name, value: value, kind: FieldKind.number);
}

/// A field with value of [int] type.
class Int extends Field<int> {
  const Int(String name, int value)
      : super(name: name, value: value, kind: FieldKind.integer);
}

/// A field with value of [String] type.
class Str extends Field<String> {
  const Str(String name, String value)
      : super(name: name, value: value, kind: FieldKind.string);
}

/// A field with value of [bool] type.
class Bool extends Field<bool> {
  // ignore: avoid_positional_boolean_parameters
  const Bool(String name, bool value)
      : super(name: name, value: value, kind: FieldKind.boolean);
}

/// A field with value of [DateTime] type.
class DTM extends Field<DateTime> {
  const DTM(String name, DateTime value)
      : super(name: name, value: value, kind: FieldKind.dateTime);
}

/// A field with value of custom type (i.e. class that implements
/// [Loggable]).
class Obj extends Field<Iterable<Field>> {
  Obj(String name, Loggable value)
      : super(name: name, value: value.toFields(), kind: FieldKind.object);
}

/// [Loggable] provides the ability to be logged as part of logging context
/// field set.
abstract class Loggable {
  /// Marshals this class to a field set.
  Iterable<Field> toFields();
}
