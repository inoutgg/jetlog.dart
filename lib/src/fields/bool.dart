part of jetlog.internals.fields;

class _StaticBool extends _StaticField<bool> implements Bool {
  // ignore:avoid_positional_boolean_parameters
  const _StaticBool(String name, bool value)
      : super(name, value, FieldKind.boolean);
}

class _LazyBool extends _LazyField<bool> implements Bool {
  _LazyBool(String name, ValueProducer<bool> value)
      : super(name, value, FieldKind.boolean);
}

/// A field with value of a [bool] type.
abstract class Bool extends Field<bool> {
  // ignore:avoid_positional_boolean_parameters
  factory Bool(String name, bool value) => _StaticBool(name, value);

  factory Bool.lazy(String name, ValueProducer<bool> producer) =>
      _LazyBool(name, producer);
}
