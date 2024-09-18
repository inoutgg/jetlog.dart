part of jetlog.fields;

final class _StaticGroup extends _StaticField<Iterable<Field>>
    implements Group {
  const _StaticGroup(String name, Iterable<Field> value)
      : super(name: name, value: value, kind: FieldKind.group);
}

/// A field as a group of other fields.
///
/// Similar to [Obj] [Group] can be used to declare fields under the same namespace.
abstract class Group extends Field<Iterable<Field>> {
  const factory Group(String name, Iterable<Field> value) = _StaticGroup;
}
