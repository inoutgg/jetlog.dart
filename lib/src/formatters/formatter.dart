import 'package:structlog/structlog.dart' show Record, Level, Field;

typedef LevelFormatCallback<T> = T Function(Level);
typedef TimestampFormatCallback<T> = T Function(DateTime);
typedef FieldsFormatCallback<T> = T Function(Iterable<Field> fields);

typedef FormatCallback<T> = T Function({
  String name,
  String level,
  String timestamp,
  String message,
  String fields,
});

/// [Formatter] is capable to format single [Record] entry.
abstract class Formatter {
  /// Formats given [record] and returns formatted string as
  /// UTF-8 bytes sequence.
  List<int> call(Record record);
}
