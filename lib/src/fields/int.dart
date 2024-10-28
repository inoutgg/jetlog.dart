part of strlog.fields;

final class _StaticInt extends _StaticField<int?> implements Int {
  const _StaticInt(String name, int? value)
      : super(name: name, value: value, kind: FieldKind.integer);
}

final class _LazyInt extends _LazyField<int?> implements Int {
  _LazyInt(String name, ValueProducer<int?> producer)
      : super(name: name, producer: producer, kind: FieldKind.integer);
}

/// A field with value of a [int?] type.
abstract class Int extends Field<int?> {
  const factory Int(String name, int? value) = _StaticInt;

  factory Int.lazy(String name, ValueProducer<int?> producer) =>
      _LazyInt(name, producer);
}
