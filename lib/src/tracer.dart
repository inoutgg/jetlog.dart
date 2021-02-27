import 'package:jetlog/src/interface.dart';

/// Tracer is used to measure time between [Interface.trace] and [Tracer.stop]
/// calls.
abstract class Tracer {
  /// Stops tracing; immediately emits a record with a [message] and
  /// measured time.
  ///
  /// If [stop] is called more than once a [TracerStoppedError]
  /// will be raised.
  void stop(String message);
}
