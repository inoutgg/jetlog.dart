import 'package:jetlog/jetlog.dart' show Logger;
import 'package:jetlog/src/timer_impl.dart';
import 'package:test/test.dart';

void main() {
  group('Timer', () {
    group('#toString', () {
      test('returns correct string representation', () {
        final l = Logger.detached();
        final t = l.startTimer('start') as TimerImpl;

        expect(
            t.toString(),
            equals('Timer(level=Level(name=DEBUG) '
                'isRunning=true '
                'startedAt=${t.startedAt} '
                'stoppedAt=${t.stoppedAt})'));

        t.stop('stop');

        expect(
            t.toString(),
            equals('Timer(level=Level(name=DEBUG) '
                'isRunning=false '
                'startedAt=${t.startedAt} '
                'stoppedAt=${t.stoppedAt})'));
      });
    });
  });
}
