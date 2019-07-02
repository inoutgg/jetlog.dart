import 'package:jetlog/src/field.dart' show Dur, DTM;
import 'package:jetlog/src/interface.dart';
import 'package:jetlog/src/level.dart';
import 'package:jetlog/src/tracer.dart';

class TracerImpl implements Tracer {
  TracerImpl(this._context) : _timer = Stopwatch();

  DateTime startAt;
  DateTime stopAt;

  final Stopwatch _timer;
  Interface _context;

  void start(String message) {
    startAt = DateTime.now();
    _context = _context.bind({DTM('start', startAt)})
      ..log(Level.trace, message);

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
    _context.bind({Dur('duration', _timer.elapsed)}).log(Level.trace, message);
  }

  @override
  String toString() {
    final buffer = StringBuffer();

    buffer
      ..write('Tracer(')
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
