import 'dart:async' show Future, StreamController;

import 'package:structlog/structlog.dart' show Handler, Record;

/// [MultiHandler] allows use of multiple handlers; it delegates record
/// down to this handlers.
class MultiHandler extends Handler {
  /// Creates a new [MultiHandler] with given handlers.
  MultiHandler(Iterable<Handler> handlers)
      : _controller = StreamController.broadcast(sync: true) {
    for (final h in handlers) {
      h.subscription = _controller.stream.listen(h.handle, onDone: h.close);
    }
  }

  final StreamController<Record> _controller;

  @override
  void handle(Record record) => _controller.add(record);

  @override
  Future<void> close() => super.close().then((_) => _controller.close());
}
