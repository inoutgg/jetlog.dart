import 'dart:async' show StreamSink;
import 'package:structlog/structlog.dart' show Handler, Record;
import 'package:structlog/formatters.dart' show Formatter;

/// [StreamHandler] delegates log records downstream.
class StreamHandler<T> extends Handler {
  StreamHandler(this._stream);

  final StreamSink<T> _stream;
  Formatter<T> _formatter;

  /// Sets records formatter.
  set formatter(Formatter<T> formatter) {
    ArgumentError.checkNotNull(formatter, 'formatter');

    _formatter = formatter;
  }

  @override
  void handle(Record record) {
    if (!filter(record)) {
      return;
    }

    final result = _formatter.format(record);

    _stream.add(result);
  }
}
