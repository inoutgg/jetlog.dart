part of jetlog.fields;

class _StaticBool extends _StaticField<bool?> implements Bool {
  // ignore:avoid_positional_boolean_parameters
  const _StaticBool(String name, bool? value)
      : super(name: name, value: value, kind: FieldKind.boolean);
}

class _LazyBool extends _LazyField<bool?> implements Bool {
  _LazyBool(String name, ValueProducer<bool?> producer)
      : super(name: name, producer: producer, kind: FieldKind.boolean);
}

/// A field with value of a [bool] type.
abstract class Bool extends Field<bool?> {
  // ignore:avoid_positional_boolean_parameters
  const factory Bool(String name, bool? value) = _StaticBool;

  factory Bool.lazy(String name, ValueProducer<bool?> producer) = _LazyBool;
}
