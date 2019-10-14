library jetlog.internals.fields;

import 'package:meta/meta.dart';

part 'fields/any.dart';
part 'fields/bool.dart';
part 'fields/double.dart';
part 'fields/dtm.dart';
part 'fields/dur.dart';
part 'fields/int.dart';
part 'fields/num.dart';
part 'fields/obj.dart';
part 'fields/str.dart';

typedef ValueProducer<V> = V Function();

/// [FieldKind] represents a [Field.value] type. It is used for [Field]
/// serialization to remove necessity to dynamically probe [Field.value] type.
class FieldKind {
  const FieldKind(this.value);

  /// Unique value for type.
  final int value;

  /// A field kind representing [bool] value type.
  static const FieldKind boolean = FieldKind(0x1);

  /// A field kind representing [DateTime] value type.
  static const FieldKind dateTime = FieldKind(0x2);

  /// A field kind representing [double] value type.
  static const FieldKind double = FieldKind(0x3);

  /// A field kind representing [Duration] value type.
  static const FieldKind duration = FieldKind(0x4);

  /// A field kind representing [int] value type.
  static const FieldKind integer = FieldKind(0x5);

  /// A field kind representing [num] value type.
  static const FieldKind number = FieldKind(0x6);

  /// A field kind representing custom value type (a class implementing
  /// [Loggable]).
  static const FieldKind object = FieldKind(0x7);

  /// A field kind representing a [String] value type.
  static const FieldKind string = FieldKind(0x8);
}

/// A [Field] used to add a key-value pair to a logger's context.
abstract class Field<V> {
  /// Creates a new [Field] with [name] and [value].
  const factory Field(
      {@required String name,
      @required V value,
      @required FieldKind kind}) = _StaticField<V>;

  /// Creates a new [Field] with [value] that is evaluated on access.
  ///
  /// Typically, this factory should be used to create a field with value that
  /// involves heavy computation.
  ///
  /// Note that [Field] specializations like [Bool], [Str], etc. also support
  /// factory with lazy evaluation of [value].
  factory Field.lazy(
      {@required String name,
      @required ValueProducer<V> producer,
      @required FieldKind kind}) = _LazyField<V>;

  /// Name of this field (a key).
  String get name;

  /// Value of this field.
  V get value;

  /// Kind of field's value, used to determine [Field.value] type without
  /// runtime lookups.
  FieldKind get kind;
}

class _StaticField<V> implements Field<V> {
  const _StaticField({this.name, this.value, this.kind});

  @override
  final String name;

  @override
  final V value;

  @override
  final FieldKind kind;

  @override
  int get hashCode => name.hashCode;

  @override
  bool operator ==(Object other) => other is Field && other.name == name;
}

class _LazyField<V> implements Field<V> {
  _LazyField({this.name, this.producer, this.kind});

  // TODO: update to late final once available in the Dart SDK.
  V _value;

  final V Function() producer;

  @override
  final String name;

  @override
  V get value => _value ??= producer();

  @override
  final FieldKind kind;

  @override
  int get hashCode => name.hashCode;

  @override
  bool operator ==(Object other) => other is Field && other.name == name;
}
