part of '../field.dart';

final class _StaticObj extends _StaticField<Iterable<Field>?> implements Obj {
  _StaticObj(String name, Loggable? value)
      : super(name: name, value: value?.toFields(), kind: FieldKind.object);
}

final class _LazyObj extends _LazyField<Iterable<Field>?> implements Obj {
  _LazyObj(String name, ValueProducer<Iterable<Field>?> producer)
      : super(name: name, producer: producer, kind: FieldKind.object);
}

/// A field with a value of a custom type (i.e., a class that implements
/// [Loggable]).
abstract class Obj extends Field<Iterable<Field>?> {
  factory Obj(String name, Loggable? value) => _StaticObj(name, value);

  factory Obj.lazy(String name, ValueProducer<Loggable?> producer) =>
      _LazyObj(name, () => producer()?.toFields());
}

/// [Loggable] provides the ability for an object to be logged as part of a
/// logging context field set.
///
/// Example:
/// ```dart
/// class User implements Loggable {
///   final String name;
///   final String email;
///   final DateTime createdAt;
///
///   User({this.name, this.email, this.createdAt});
///
///   @override
///   Iterable<Field> toFields() =>
///       {
///         Str('name', name),
///         Str('email', email),
///         DTM('createdAt', createdAt),
///       };
/// }
///
/// final user = User(
///    name: 'Roman Vanesyan',
///    email: 'me@romanvanesyan.com',
///    createdAt: DateTime.now());
///
///  logger
///      .bind(Obj('user', user), DTM('authenticated_at', DateTime.now()))
///      .info('successfully authenticated');
/// ```
abstract class Loggable {
  /// Marshals this class to set of [Field]s.
  Iterable<Field> toFields();
}
