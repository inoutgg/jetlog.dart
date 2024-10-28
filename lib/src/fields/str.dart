part of strlog.fields;

final class _StaticStr extends _StaticField<String?> implements Str {
  const _StaticStr(String name, String? value)
      : super(name: name, value: value, kind: FieldKind.string);
}

final class _LazyStr extends _LazyField<String?> implements Str {
  _LazyStr(String name, ValueProducer<String?> producer)
      : super(name: name, producer: producer, kind: FieldKind.string);
}

/// A field with value of a [String] type.
abstract class Str extends Field<String?> {
  const factory Str(String name, String? value) = _StaticStr;

  factory Str.lazy(String name, ValueProducer<String?> producer) =>
      _LazyStr(name, producer);
}
