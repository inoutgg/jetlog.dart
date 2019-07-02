import 'package:test/test.dart';
import 'package:jetlog/jetlog.dart' show Logger;
import 'package:jetlog/src/tracer_impl.dart';

void main() {
  group('Tracer', () {
    group('#toString', () {
      test('returns correct string representation', () {
        final l = Logger.detached();
        final t = l.trace('start') as TracerImpl;

        expect(
            t.toString(),
            equals(
                'Tracer(isRunning=true startAt=${t.startAt} stopAt=${t.stopAt})'));

        t.stop('stop');

        expect(
            t.toString(),
            equals(
                'Tracer(isRunning=false startAt=${t.startAt} stopAt=${t.stopAt})'));
      });
    });
  });
}
