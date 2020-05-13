import 'package:jetlog/jetlog.dart' show Logger, TraceLog;
import 'package:jetlog/src/tracer_impl.dart';
import 'package:test/test.dart';

void main() {
  group('Tracer', () {
    group('#toString', () {
      test('returns correct string representation', () {
        final l = Logger.detached();
        final t = l.trace('start') as TracerImpl;

        expect(
            t.toString(),
            equals('Tracer(level=Level(name=DEBUG) '
                'isRunning=true '
                'startAt=${t.startAt} '
                'stopAt=${t.stopAt})'));

        t.stop('stop');

        expect(
            t.toString(),
            equals('Tracer(level=Level(name=DEBUG) '
                'isRunning=false '
                'startAt=${t.startAt} '
                'stopAt=${t.stopAt})'));
      });
    });
  });
}
