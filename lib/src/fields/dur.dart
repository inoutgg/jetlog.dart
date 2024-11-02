part of '../field.dart';

final class _StaticDur extends _StaticField<Duration?> implements Dur {
  const _StaticDur(String name, Duration? value)
      : super(name: name, value: value, kind: FieldKind.duration);
}

final class _LazyDur extends _LazyField<Duration?> implements Dur {
  _LazyDur(String name, ValueProducer<Duration?> producer)
      : super(name: name, producer: producer, kind: FieldKind.duration);
}

/// A field with value of a [Duration?] type.
abstract class Dur extends Field<Duration?> {
  const factory Dur(String name, Duration? value) = _StaticDur;

  factory Dur.lazy(String name, ValueProducer<Duration?> producer) =>
      _LazyDur(name, producer);
}
