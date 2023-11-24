part of jetlog.fields;

final class _StaticNum extends _StaticField<num?> implements Num {
  const _StaticNum(String name, num? value)
      : super(name: name, value: value, kind: FieldKind.number);
}

final class _LazyNum extends _LazyField<num?> implements Num {
  _LazyNum(String name, ValueProducer<num?> producer)
      : super(name: name, producer: producer, kind: FieldKind.number);
}

/// A field with value of a [num] type.
abstract class Num extends Field<num?> {
  const factory Num(String name, num? value) = _StaticNum;

  factory Num.lazy(String name, ValueProducer<num?> producer) =>
      _LazyNum(name, producer);
}
