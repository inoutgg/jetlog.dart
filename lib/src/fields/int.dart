part of jetlog.internals.fields;

class _StaticInt extends _StaticField<int> implements Int {
  const _StaticInt(String name, int value)
      : super(name, value, FieldKind.integer);
}

class _LazyInt extends _LazyField<int> implements Int {
  _LazyInt(String name, ValueProducer<int> value)
      : super(name, value, FieldKind.integer);
}

/// A field with value of a [int] type.
abstract class Int extends Field<int> {
  factory Int(String name, int value) =>
      _StaticInt(name, value);

  factory Int.lazy(String name, ValueProducer<int> producer) =>
      _LazyInt(name, producer);
}
