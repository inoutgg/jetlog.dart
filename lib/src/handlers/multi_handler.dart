import 'dart:async' show Future, StreamController;

import 'package:jetlog/jetlog.dart' show Filter, Handler, Record;

/// [MultiHandler] composites multiple handlers into one handler; any logging
/// records that are delegated to this handler will be propagated to composed
/// handlers.
class MultiHandler extends Handler {
  /// Creates a new [MultiHandler] with given handlers.
  MultiHandler(Iterable<Handler> handlers)
      : _controller = StreamController.broadcast(sync: true) {
    if (handlers.isEmpty) {
      throw ArgumentError.value(
          handlers, 'handlers', 'Must be non empty iterable collection');
    }

    for (final h in handlers) {
      h.subscription = _controller.stream.listen(h.handle, onDone: h.close);
    }
  }

  Filter? _filter;

  final StreamController<Record> _controller;

  /// Sets records filterer.
  ///
  /// Set filterer behaves the same way as a [Logger] filter.
  set filter(Filter filter) => _filter = filter;

  @override
  void handle(Record record) {
    if (_filter != null && !_filter!(record)) {
      return;
    }

    _controller.add(record);
  }

  @override
  Future<void> close() async {
    await _controller.close();

    return super.close();
  }
}
