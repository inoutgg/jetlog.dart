import 'package:jetlog/src/field.dart' show Field;
import 'package:jetlog/src/interface.dart';

/// [Timer] is used to measure time between [Interface.startTimer] and [Timer.stop]
/// calls.
abstract interface class Timer {
  /// Stops tracing; immediately emits a record with a [message] and
  /// measured time.
  ///
  /// If [stop] is called more than once a [TracerStoppedError]
  /// will be raised.
  void stop(String message, [Iterable<Field>? fields]);
}
