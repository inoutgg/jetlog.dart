import 'package:jetlog/src/field.dart' show DTM, Dur, Field;
import 'package:jetlog/src/interface.dart';
import 'package:jetlog/src/level.dart';
import 'package:jetlog/src/tracer.dart';

class TracerImpl implements Tracer {
  TracerImpl(this._context, [this._level = Level.debug]) : _timer = Stopwatch();

  late final DateTime startAt;
  DateTime? stopAt;
  Interface _context;

  final Stopwatch _timer;
  final Level _level;

  @pragma('vm:prefer-inline')
  void start(String message) {
    startAt = DateTime.now();
    _context = _context.bind({DTM('start', startAt)})..log(_level, message);

    _timer.start();
  }

  @override
  void stop(String message, {Level? level, Iterable<Field>? fields}) {
    if (_timer.isRunning) {
      _timer.stop();
      stopAt = DateTime.now();
      _context.bind({
        Dur('duration', _timer.elapsed),
        if (fields != null) ...fields
      }).log(level ?? _level, message);
    }
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
