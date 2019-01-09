import 'package:structlog/structlog.dart' show Record;

abstract class Formatter<T> {
  T format(Record record);
}
