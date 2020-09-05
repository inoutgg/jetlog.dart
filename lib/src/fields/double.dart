part of jetlog.fields;

class _StaticDouble extends _StaticField<double?> implements Double {
  const _StaticDouble(String name, double? value)
      : super(name: name, value: value, kind: FieldKind.double);
}

class _LazyDouble extends _LazyField<double?> implements Double {
  _LazyDouble(String name, ValueProducer<double?> producer)
      : super(name: name, producer: producer, kind: FieldKind.double);
}

/// A field with value of a [double] type.
abstract class Double extends Field<double?> {
  const factory Double(String name, double? value) = _StaticDouble;

  factory Double.lazy(String name, ValueProducer<double?> producer) =>
      _LazyDouble(name, producer);
}
