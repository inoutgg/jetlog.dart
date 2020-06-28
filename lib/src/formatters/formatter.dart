import 'package:jetlog/jetlog.dart' show Record, Level, Field, FieldKind;

typedef LevelFormatter<R> = R Function(Level);
typedef TimestampFormatter<R> = R Function(DateTime);
typedef FieldFormatter<R> = R Function(Field<Object>);

/// [Formatter] is capable to format single [Record] entry.
typedef Formatter = List<int> Function(Record);

mixin FormatterBase<R> {
  final Map<FieldKind, FieldFormatter<R>> _registeredFieldFormatters = {};

  void setFieldFormatter(FieldKind kind, FieldFormatter<R> formatter) {
    _registeredFieldFormatters[kind] = formatter;
  }

  FieldFormatter<R> getFieldFormatter(FieldKind kind) {
    final formatter = _registeredFieldFormatters[kind];
    if (formatter == null) {
      throw StateError(
          'No registered formatters were provided for given field kind $kind!');
    }

    return formatter;
  }
}
