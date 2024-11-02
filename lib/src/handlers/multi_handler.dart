import 'dart:async' show Future, StreamController;

import 'package:strlog/strlog.dart' show Filter, Handler, Record;

/// [MultiHandler] composites multiple handlers into one handler; any logging
/// records that are delegated to this handler will be propagated to composed
/// handlers.
class MultiHandler extends Handler {
  /// Creates a new [MultiHandler] with given handlers.
  MultiHandler(Iterable<Handler> handlers)
      : _controller = StreamController.broadcast(sync: true),
        _isClosed = false {
    if (handlers.isEmpty) {
      throw ArgumentError.value(
          handlers, 'handlers', 'Must be non empty iterable collection');
    }

    for (final h in handlers) {
      h.subscription = _controller.stream.listen(h.handle, onDone: h.close);
    }
  }

  Filter? _filter;

  bool _isClosed;
  final StreamController<Record> _controller;

  /// Sets records filter.
  ///
  /// Set filter behaves the same way as a [Logger] filter.
  set filter(Filter filter) => _filter = filter;

  @override
  void handle(Record record) {
    if (_filter != null && !_filter!(record)) {
      return;
    }

    _controller.add(record);
  }

  /// Closes the handler.
  ///
  /// After closing the handler, it can't handle any new records.
  /// Calling close() multiple times has no effect.
  ///
  /// All managed handlers will be automatically closed when this handler is closed.
  @override
  Future<void> close() async {
    if (_isClosed) {
      return;
    }

    _isClosed = true;
    await super.close();
    await _controller.close();
  }
}
