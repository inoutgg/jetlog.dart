part of strlog.fields;

final class _StaticDTM extends _StaticField<DateTime?> implements DTM {
  const _StaticDTM(String name, DateTime? value)
      : super(name: name, value: value, kind: FieldKind.dateTime);
}

final class _LazyDTM extends _LazyField<DateTime?> implements DTM {
  _LazyDTM(String name, ValueProducer<DateTime?> producer)
      : super(name: name, producer: producer, kind: FieldKind.dateTime);
}

/// A field with value of a [DateTime] type.
abstract class DTM extends Field<DateTime?> {
  const factory DTM(String name, DateTime? value) = _StaticDTM;

  factory DTM.lazy(String name, ValueProducer<DateTime?> producer) =>
      _LazyDTM(name, producer);
}
