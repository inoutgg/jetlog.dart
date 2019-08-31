part of jetlog.internals.fields;

class _StaticNum extends _StaticField<num> implements Num {
  const _StaticNum(String name, num value)
      : super(name, value, FieldKind.number);
}

class _LazyNum extends _LazyField<num> implements Num {
  _LazyNum(String name, ValueProducer<num> value)
      : super(name, value, FieldKind.number);
}

/// A field with value of a [num] type.
abstract class Num extends Field<num> {
  factory Num(String name, num value) =>
      _StaticNum(name, value);

  factory Num.lazy(String name, ValueProducer<num> producer) =>
      _LazyNum(name, producer);
}
