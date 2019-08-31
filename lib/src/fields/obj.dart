part of jetlog.internals.fields;

class _StaticObj extends _StaticField<Iterable<Field>> implements Obj {
  _StaticObj(String name, Loggable value)
      : super(name, value?.toFields(), FieldKind.object);
}

class _LazyObj extends _LazyField<Iterable<Field>> implements Obj {
  _LazyObj(String name, ValueProducer<Iterable<Field>> value)
      : super(name, value, FieldKind.object);
}

/// A field with value of custom type (i.e. class that implements
/// [Loggable]).
abstract class Obj extends Field<Iterable<Field>> {
  factory Obj(String name, Loggable value) => _StaticObj(name, value);

  factory Obj.lazy(String name, ValueProducer<Loggable> producer) =>
      _LazyObj(name, () => producer()?.toFields());
}

/// [Loggable] provides the ability to object to be logged as part of
/// logging context field set.
abstract class Loggable {
  /// Marshals this class to a field set.
  Iterable<Field> toFields();
}
