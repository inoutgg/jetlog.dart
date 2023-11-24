import 'package:jetlog/src/field.dart' show Field, Dur, DTM;
import 'package:jetlog/src/interface.dart';
import 'package:jetlog/src/level.dart';
import 'package:jetlog/src/timer.dart';

class TimerImpl implements Timer {
  TimerImpl(this._context, [this._level = Level.debug])
      : _stopwatch = Stopwatch();

  late final DateTime startedAt;
  late final DateTime stoppedAt;
  Interface _context;
  bool _startGuard = false;

  final Stopwatch _stopwatch;
  final Level _level;

  @pragma('vm:prefer-inline')
  void start(String message) {
    // Prevent multiple calls to [start].
    if (_startGuard) return;
    _startGuard = true;

    startedAt = DateTime.now();
    _context = _context.bind({DTM('started_at', startedAt)})
      ..log(_level, message);

    _stopwatch.start();
  }

  @override
  void stop(String message, {Level? level, Iterable<Field>? fields}) {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      stoppedAt = startedAt.add(_stopwatch.elapsed);
      _context.bind({
        Dur('duration', _stopwatch.elapsed),
        DTM('stopped_at', stoppedAt),
        ...?fields
      }).log(level ?? _level, message);
    }
  }

  @override
  String toString() {
    final buffer = StringBuffer();

    buffer
      ..write('Timer(')
      ..write('level=')
      ..write(_level)
      ..write(' ')
      ..write('isRunning=')
      ..write(_stopwatch.isRunning)
      ..write(' ')
      ..write('startedAt=')
      ..write(startedAt.toString())
      ..write(' ')
      ..write('stoppedAt=')
      ..write(stoppedAt.toString())
      ..write(')');

    return buffer.toString();
  }
}
