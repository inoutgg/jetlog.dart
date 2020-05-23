import 'package:jetlog/jetlog.dart' show Record, Level, Field;

typedef LevelFormatter<L> = L Function(Level);
typedef TimestampFormatter<T> = T Function(DateTime);
typedef FieldsFormatter<F> = F Function(Iterable<Field>?);

/// [Formatter] is capable to format single [Record] entry.
typedef Formatter = List<int> Function(Record);
