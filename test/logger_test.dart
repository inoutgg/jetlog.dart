import 'package:jetlog/handlers.dart' show MemoryHandler;
import 'package:jetlog/jetlog.dart'
    show Logger, Level, Record, DefaultLog, TraceLog;
import 'package:jetlog/src/logger_impl.dart' show LoggerImpl;
import 'package:test/test.dart';

class _Filter {
  bool call(Record record) => true;
}

void main() {
  group('Logger', () {
    group('#getLogger', () {
      test('Creates correct hierarchy', () {
        final LoggerImpl logger = Logger.getLogger('a.b.c.d') as LoggerImpl;

        expect(logger.name, equals('a.b.c.d'));
        expect(logger.parent.name, equals('a.b.c'));
        expect(logger.parent.parent.name, equals('a.b'));
        expect(logger.parent.parent.parent.name, equals('a'));
        expect(logger.parent.parent.parent.parent.name, equals('ROOT_LOGGER'));
        expect(logger.parent.parent.parent.parent.parent, isNull);
      });

      test('Returns a singleton', () {
        final a1 = Logger.getLogger('a');
        final a2 = Logger.getLogger('a');
        final b = Logger.getLogger('a.b');

        expect(a1, same(a2));
        expect(a1, same((b as LoggerImpl).parent));
      });

      test('Name cannot start or end with a `.`', () {
        expect(() => Logger.getLogger('.a'), throwsArgumentError);
        expect(() => Logger.getLogger('a.'), throwsArgumentError);
      });
    });

    group('#detached', () {
      test('Creates unique instance', () {
        final a1 = Logger.detached('a');
        final a2 = Logger.detached('a');
        final a = Logger.getLogger('a');

        expect(a1, isNot(same(a2)));
        expect(a1, isNot(same(a)));
        expect(a2, isNot(same(a)));
      });

      test('`parent` is `null`', () {
        final logger = Logger.detached('a') as LoggerImpl;

        expect(logger.parent, isNull);
      });

      test('`children` is `null`', () {
        final logger = Logger.detached('a') as LoggerImpl;

        expect(logger.children, null);
      });
    });

    group('.root', () {
      test('#level defaults to `Level.info`', () {
        expect(Logger.root.level, Level.info);
      });
    });

    group('#toString', () {
      test('returns correct string representation for detached logger', () {
        const level = Level.info;
        final logger = Logger.detached('logger')..level = level;
        final unnamedLogger = Logger.detached();

        expect(logger.toString(), 'Logger(name=logger, level=${level.name})');
        expect(unnamedLogger.toString(), 'Logger(level=${level.name})');
      });

      test('returns correct string representation for managed logger', () {
        const level = Level.debug;
        final logger = Logger.getLogger('DEBUG.TEST.LOGGER')..level = level;
        final logger2 = Logger.getLogger('DEBUG.TEST.LOGGER.2');

        expect(logger.toString(),
            'Logger(name=DEBUG.TEST.LOGGER, level=${level.name})');
        expect(logger2.toString(),
            'Logger(name=DEBUG.TEST.LOGGER.2, level=${level.name})');
      });

      test('returns correct string representation for noop logger', () {
        const level = Level.fatal;
        final logger = Logger.noop('NOOP_LOGGER')..level = level;
        final unnamedLogger = Logger.noop()..level = level;

        expect(logger.toString(),
            'NoopLogger(name=NOOP_LOGGER, level=${level.name})');
        expect(unnamedLogger.toString(), 'NoopLogger(level=${level.name})');
      });
    });

    group('#level', () {
      test('when set to `null` inherits level from parent (HIERARCHY)', () {
        final a = Logger.getLogger('a')..level = null;
        final b = Logger.getLogger('a.b')..level = null;

        expect(a.level, same(Logger.root.level));
        expect(b.level, same(Logger.root.level));

        b.level = Level.danger;

        expect(b.level, same(Level.danger));

        a.level = Level.all;
        b.level = null; // explicitly set to null.

        expect(b.level, same(a.level));
      });

      test('inherits parent logger severity level (HIERARCHY)', () {
        final e = Logger.getLogger('e');

        expect(e.level, same(Logger.root.level));

        e.level = Level.all;
        final f = Logger.getLogger('e.f');

        expect(f.level, same(e.level));

        f.level = Level.warning;
        final g = Logger.getLogger('e.f.g');

        expect(g.level, same(f.level));
      });

      test('defaults to `Level.info`', () {
        final logger1 = Logger.getLogger('logger1');
        final logger2 = Logger.detached('logger2');

        expect(logger1.level, same(Level.info));
        expect(logger2.level, same(Level.info));
      });
    });

    group('#isEnabledFor', () {
      test('works correctly', () {
        final a = Logger.getLogger('a')..level = Level.all;
        final b = Logger.getLogger('a.b')..level = Level.off;
        final c = Logger.getLogger('a.b.c')..level = Level.info;

        expect(a.isEnabledFor(Level.debug), isTrue);
        expect(a.isEnabledFor(Level.info), isTrue);
        expect(a.isEnabledFor(Level.fatal), isTrue);

        expect(b.isEnabledFor(Level.warning), isFalse);
        expect(b.isEnabledFor(Level.danger), isFalse);

        expect(c.isEnabledFor(Level.info), isTrue);
        expect(c.isEnabledFor(Level.warning), isTrue);
        expect(c.isEnabledFor(Level.debug), isFalse);
      });

      test('throws error if `Level.all` or `Level.off` is provided', () {
        final logger1 = Logger.getLogger('logger1');
        final logger2 = Logger.detached('logger2');

        expect(() => logger1.isEnabledFor(Level.off), throwsArgumentError);
        expect(() => logger1.isEnabledFor(Level.all), throwsArgumentError);
        expect(() => logger2.isEnabledFor(Level.off), throwsArgumentError);
        expect(() => logger2.isEnabledFor(Level.all), throwsArgumentError);
      });

      test('throws error if `null` is provided', () {
        final logger = Logger.detached();

        expect(() => logger.isEnabledFor(null), throwsArgumentError);
      });
    });

    group('NoopLogger', () {
      test('works normally', () {
        final l = Logger.noop();

        expect(() => l.handler = MemoryHandler(), returnsNormally);
        expect(() => l.handler = null, returnsNormally);

        expect(() => l.filter = _Filter(), returnsNormally);
        expect(() => l.filter = null, returnsNormally);

        expect(() => l.log(Level.info, 'test'), returnsNormally);
        expect(() => l.debug('test'), returnsNormally);
        expect(() => l.trace('test'), returnsNormally);
        expect(() => l.info('test'), returnsNormally);
        expect(() => l.warning('test'), returnsNormally);
        expect(() => l.danger('test'), returnsNormally);
        expect(() => l.fatal('test'), returnsNormally);
        expect(l.bind, returnsNormally);

        final b = l.bind();

        expect(() => b.log(Level.info, 'bind test'), returnsNormally);
        expect(() => b.debug('bind test'), returnsNormally);
        expect(() => l.trace('test'), returnsNormally);
        expect(() => b.info('bind test'), returnsNormally);
        expect(() => b.warning('bind test'), returnsNormally);
        expect(() => b.danger('bind test'), returnsNormally);
        expect(() => b.fatal('bind test'), returnsNormally);

        final t = l.trace('test trace');

        expect(() => t.stop('test trace'), returnsNormally);
      });
    });
  });
}
