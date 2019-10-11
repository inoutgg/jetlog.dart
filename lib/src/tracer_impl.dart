import 'package:jetlog/src/field.dart' show Dur, DTM;
import 'package:jetlog/src/interface.dart';
import 'package:jetlog/src/level.dart';
import 'package:jetlog/src/tracer.dart';

class TracerImpl implements Tracer {
  TracerImpl(this._context, [this._level]) : _timer = Stopwatch();

  DateTime startAt;
  DateTime stopAt;

  final Stopwatch _timer;
  final Level _level;
  Interface _context;

  void start(String message) {
    startAt = DateTime.now();
    _context = _context.bind({DTM('start', startAt)})..log(_level, message);

    _timer.start();
  }

  @override
  void stop(String message) {
    if (_timer.isRunning) {
      _timer.stop();
    } else {
      throw TracerStoppedError('Tracer has been already stopped!');
    }

    stopAt = DateTime.now();
    _context.bind({Dur('duration', _timer.elapsed)}).log(_level, message);
  }

  @override
  String toString() {
    final buffer = StringBuffer();

    buffer
      ..write('Tracer(')
      ..write('level=')
      ..write(_level)
      ..write(' ')
      ..write('isRunning=')
      ..write(_timer.isRunning)
      ..write(' ')
      ..write('startAt=')
      ..write(startAt.toString())
      ..write(' ')
      ..write('stopAt=')
      ..write(stopAt.toString())
      ..write(')');

    return buffer.toString();
  }
}
