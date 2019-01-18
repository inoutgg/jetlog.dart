import 'package:structlog/src/field.dart' show Dur;
import 'package:structlog/src/interface.dart';
import 'package:structlog/src/level.dart';
import 'package:structlog/src/tracer.dart';

class TracerImpl implements Tracer {
  TracerImpl(this._context) : _timer = Stopwatch() {
    _timer.start();
  }

  final Interface _context;
  final Stopwatch _timer;

  @override
  void stop(String message) {
    if (_timer.isRunning) {
      _timer.stop();
    } else {
      throw TracerStoppedError('Tracer has been already stopped!');
    }

    _context.bind([Dur('duration', _timer.elapsed)]).log(Level.trace, message);
  }
}
