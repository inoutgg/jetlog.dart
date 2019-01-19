import 'package:test/test.dart';
import 'package:structlog/structlog.dart'
    show Logger, Level, HandlerRegisterError;
import 'package:structlog/handlers.dart' show MemoryHandler;
import 'package:structlog/src/internals/logger.dart' show LoggerImpl;

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

    group('#Logger', () {
      test('Creates unique instance', () {
        final a1 = Logger('a');
        final a2 = Logger('a');
        final a = Logger.getLogger('a');

        expect(a1, isNot(same(a2)));
        expect(a1, isNot(same(a)));
        expect(a2, isNot(same(a)));
      });

      test('`parent` is `null`', () {
        final logger = Logger('a') as LoggerImpl;

        expect(logger.parent, isNull);
      });

      test('`children` are empty', () {
        final logger = Logger('a') as LoggerImpl;

        expect(logger.children, Set<LoggerImpl>());
      });
    });

    group('.root', () {
      test('#level defaults to `Level.info`', () {
        expect(Logger.root.level, Level.info);
      });
    });

    group('#toString', () {
      test('returns correct string representation', () {
        const level = Level.info;
        final logger = Logger('logger')..level = level;

        expect(logger.toString(), '<Logger name=logger, level=${level.name}>');
      });
    });

    group('#level', () {
      test(
          'when `Logger#level` set to `null` inherits level '
          'from parent (HIERARCHY)', () {
        final a = Logger.getLogger('a');
        final b = Logger.getLogger('a.b');

        expect(a.level, same(Logger.root.level));

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
        final logger2 = Logger('logger2');

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

        expect(b.isEnabledFor(Level.trace), isFalse);
        expect(b.isEnabledFor(Level.warning), isFalse);
        expect(b.isEnabledFor(Level.danger), isFalse);

        expect(c.isEnabledFor(Level.info), isTrue);
        expect(c.isEnabledFor(Level.warning), isTrue);
        expect(c.isEnabledFor(Level.debug), isFalse);
      });

      test('throws error if `Level.all` or `Level.off` is provided', () {
        final logger1 = Logger.getLogger('logger1');
        final logger2 = Logger('logger2');

        expect(() => logger1.isEnabledFor(Level.off), throwsArgumentError);
        expect(() => logger1.isEnabledFor(Level.all), throwsArgumentError);
        expect(() => logger2.isEnabledFor(Level.off), throwsArgumentError);
        expect(() => logger2.isEnabledFor(Level.all), throwsArgumentError);
      });

      test('throws error if `null` is provided', () {
        final logger = Logger();

        expect(() => logger.isEnabledFor(null), throwsArgumentError);
      });
    });

    group('#addHandler', () {
      test('throws error when register the same handler twice a time', () {
        final handler = MemoryHandler();
        final logger = Logger.getLogger('logger');

        expect(() => logger.addHandler(handler), returnsNormally);
        expect(() => logger.addHandler(handler),
            throwsA(const TypeMatcher<HandlerRegisterError>()));
      });
    });
  });
}
