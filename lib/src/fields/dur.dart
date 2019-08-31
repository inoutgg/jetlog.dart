part of jetlog.internals.fields;

class _StaticDur extends _StaticField<Duration> implements Dur {
  const _StaticDur(String name, Duration value)
      : super(name, value, FieldKind.duration);
}

class _LazyDur extends _LazyField<Duration> implements Dur {
  _LazyDur(String name, ValueProducer<Duration> value)
      : super(name, value, FieldKind.duration);
}

/// A field with value of a [Duration] type.
abstract class Dur extends Field<Duration> {
  factory Dur(String name, Duration value) =>
      _StaticDur(name, value);

  factory Dur.lazy(String name, ValueProducer<Duration> producer) =>
      _LazyDur(name, producer);
}
