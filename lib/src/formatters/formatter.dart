import 'package:jetlog/jetlog.dart' show Record, Level, Field, FieldKind;

typedef LevelFormatter<R> = R Function(Level);
typedef TimestampFormatter<R> = R Function(DateTime);
typedef FieldFormatter<R> = R Function(Field);

/// [Formatter] is capable to format single [Record] entry.
typedef Formatter = List<int> Function(Record);

/// Base mixin for implementing [Formatter].
///
/// Contains default implementations of common methods across formatters.
mixin FormatterBase<R> {
  final Map<FieldKind, FieldFormatter<R>> _registeredFieldFormatters = {};

  /// Registers [formatter] for a given field [kind].
  void setFieldFormatter(FieldKind kind, FieldFormatter<R> formatter) {
    _registeredFieldFormatters[kind] = formatter;
  }

  /// Returns registered formatter for a give field [kind].
  ///
  /// If no formatter is registered for given field [kind] throws an
  /// appropriated [StateError].
  FieldFormatter<R> getFieldFormatter(FieldKind kind) {
    final formatter = _registeredFieldFormatters[kind];
    if (formatter == null) {
      throw StateError(
          'No registered formatters were provided for given field kind $kind!');
    }

    return formatter;
  }
}
