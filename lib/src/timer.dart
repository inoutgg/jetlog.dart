import 'package:strlog/src/field.dart' show Field;
import 'package:strlog/src/level.dart';
import 'package:strlog/src/interface.dart';

/// [Timer] is used to measure time between [Interface.startTimer] and [Timer.stop]
/// calls.
abstract interface class Timer {
  /// Stops timer and outputs a log record containing a [message] and the measured time between
  /// the [Interface.startTimer] call and this [stop] call.
  /// 
  /// An optional [level] can be specified to control the output log level, and
  /// additional [fields] can be added to provide extra context in the log record.
  void stop(String message, {Level? level, Iterable<Field>? fields});
}
