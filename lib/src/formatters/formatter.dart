import 'package:jetlog/jetlog.dart' show Record, Level, Field;

typedef LevelFormatCallback<L> = L Function(Level);
typedef TimestampFormatCallback<T> = T Function(DateTime);
typedef FieldsFormatCallback<F> = F Function(Iterable<Field> fields);

typedef FormatCallback<R, T, L, F> = R Function({
  String name,
  T timestamp,
  L level,
  String message,
  F fields,
});

/// [Formatter] is capable to format single [Record] entry.
abstract class Formatter {
  /// Formats given [record] and returns formatted string as
  /// UTF-8 bytes sequence.
  List<int> call(Record record);
}
