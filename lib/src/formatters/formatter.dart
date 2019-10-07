import 'package:jetlog/jetlog.dart' show Record, Level, Field;

typedef LevelFormatter<L> = L Function(Level);
typedef TimestampFormatter<T> = T Function(DateTime);
typedef FieldsFormatter<F> = F Function(Iterable<Field>);

/// [Formatter] is capable to format single [Record] entry.
abstract class Formatter {
  /// Formats given [record] and returns formatted string as
  /// UTF-8 bytes sequence.
  List<int> call(Record record);
}
