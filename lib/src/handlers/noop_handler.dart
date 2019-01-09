import 'package:structlog/structlog.dart' show Handler, Record;

/// [NoopHandler] is no-operation handler used to discard incoming records.
class NoopHandler extends Handler {
  NoopHandler();

  @override
  void handle(Record record) {/* noop */}
}
