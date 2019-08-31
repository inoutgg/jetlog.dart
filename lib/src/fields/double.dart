part of jetlog.internals.fields;

class _StaticDouble extends _StaticField<double> implements Double {
  const _StaticDouble(String name, double value)
      : super(name, value, FieldKind.double);
}

class _LazyDouble extends _LazyField<double> implements Double {
  _LazyDouble(String name, ValueProducer<double> value)
      : super(name, value, FieldKind.double);
}

/// A field with value of a [double] type.
abstract class Double extends Field<double> {
  factory Double(String name, double value) =>
      _StaticDouble(name, value);

  factory Double.lazy(String name, ValueProducer<double> producer) =>
      _LazyDouble(name, producer);
}
