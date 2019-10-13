part of jetlog.internals.fields;

class _Any {
  const _Any();

  Field<dynamic> call(String name, dynamic value) {
    if (value is bool) {
      return Bool(name, value);
    } else if (value is double) {
      return Double(name, value);
    } else if (value is DateTime) {
      return DTM(name, value);
    } else if (value is Duration) {
      return Dur(name, value);
    } else if (value is int) {
      return Int(name, value);
    } else if (value is num) {
      return Num(name, value);
    } else if (value is Loggable) {
      return Obj(name, value);
    } else if (value is String) {
      return Str(name, value);
    }

    throw StateError('Unknown `value` type!');
  }

  Field<dynamic> lazy(String name, ValueProducer<dynamic> producer) {
    if (producer is ValueProducer<bool>) {
      return Bool.lazy(name, producer);
    } else if (producer is ValueProducer<double>) {
      return Double.lazy(name, producer);
    } else if (producer is ValueProducer<DateTime>) {
      return DTM.lazy(name, producer);
    } else if (producer is ValueProducer<Duration>) {
      return Dur.lazy(name, producer);
    } else if (producer is ValueProducer<int>) {
      return Int.lazy(name, producer);
    } else if (producer is ValueProducer<num>) {
      return Num.lazy(name, producer);
    } else if (producer is ValueProducer<Loggable>) {
      return Obj.lazy(name, producer);
    } else if (producer is ValueProducer<String>) {
      return Str.lazy(name, producer);
    }

    throw StateError('Unknown `producer` type!');
  }
}

/// [Any] takes a key and an arbitrary values and choose the one that fits.
///
/// Note that the [Any] unlike other particular types of [Field] is not a
/// subclass of it, but rather an instance of callable class that
/// is designed to mimic `Field`'s API. As so runtime checks like `field is Any`
/// won't produce anything meaningful.
///
/// As [Any] makes runtime type checking make sure that it is used only
/// where it is necessary, otherwise use one of predefined fields.
// ignore:constant_identifier_names
const _Any Any = _Any();
