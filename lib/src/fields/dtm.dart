part of jetlog.internals.fields;

class _StaticDTM extends _StaticField<DateTime> implements DTM {
  const _StaticDTM(String name, DateTime value)
      : super(name, value, FieldKind.dateTime);
}

class _LazyDTM extends _LazyField<DateTime> implements DTM {
  _LazyDTM(String name, ValueProducer<DateTime> value)
      : super(name, value, FieldKind.dateTime);
}

/// A field with value of a [DateTime] type.
abstract class DTM extends Field<DateTime> {
  factory DTM(String name, DateTime value) =>
      _StaticDTM(name, value);

  factory DTM.lazy(String name, ValueProducer<DateTime> producer) =>
      _LazyDTM(name, producer);
}
