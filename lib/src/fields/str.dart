part of jetlog.internals.fields;

class _StaticStr extends _StaticField<String> implements Str {
  const _StaticStr(String name, String value)
      : super(name, value, FieldKind.string);
}

class _LazyStr extends _LazyField<String> implements Str {
  _LazyStr(String name, ValueProducer<String> value)
      : super(name, value, FieldKind.string);
}

/// A field with value of a [String] type.
abstract class Str extends Field<String> {
  factory Str(String name, String value) =>
      _StaticStr(name, value);

  factory Str.lazy(String name, ValueProducer<String> producer) =>
      _LazyStr(name, producer);
}
