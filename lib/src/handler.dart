import 'dart:async' show StreamSubscription;

import 'package:structlog/src/filter.dart' show Filterer;
import 'package:structlog/src/logger.dart' show Logger;
import 'package:structlog/src/record.dart' show Record;

/// An error thrown when the same instance of [Handler] is registered twice a
/// time for the same logger.
class HandlerRegisterError extends Error {
  HandlerRegisterError(this.message);

  /// This error message.
  final String message;
}

/// Handler is capable to process logging [Record]s as the are added to a
/// [Logger].
abstract class Handler extends Filterer {
  StreamSubscription<Record> _subscription;

  /// Sets subscription to a specific logger. Do not call this directly.
  set subscription(StreamSubscription<Record> subscription) =>
      _subscription = subscription;

  /// Handles incoming record.
  void handle(Record record);

  /// Cancels subscription to a logger stream and frees dedicated resources.
  ///
  /// [Handler.close] is called as part of the [Logger.close] call on the logger
  /// this [Handler] is subscribed to, therefore, it is unnecessary to call
  /// this after logger close.
  ///
  /// Override this if additional operations are needed to free allot
  /// resources.
  Future<void> close() =>
      // ignore: avoid_annotating_with_dynamic
      _subscription?.cancel()?.then((dynamic _) => _subscription = null);
}
