import 'dart:async' show StreamSubscription;

import 'package:jetlog/src/logger.dart' show Logger;
import 'package:jetlog/src/record.dart' show Record;

/// Handler is capable to process logging [Record]s as the are added to a
/// [Logger].
abstract class Handler {
  StreamSubscription<Record> _subscription;

  /// Sets subscription to a specific logger. DO NOT set this field directly.
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
  Future<void> close() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
