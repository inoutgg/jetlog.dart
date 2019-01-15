import 'package:test/test.dart';
import 'package:structlog/structlog.dart' show Logger, Level;
import 'package:structlog/src/internals/logger.dart' show LoggerImpl;

void main() {
  group('Logger', () {
    group('Logger#getLogger', () {
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

      test('Name cannot start with a `.`', () {
        expect(() => Logger.getLogger('.a'), throwsArgumentError);
      });
    });

    group('Logger#Logger', () {
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

    group('Logger.root', () {
      test('#level defaults to `Level.info`', () {
        expect(Logger.root.level, Level.info);
      });
    });

    group('Logger#level', () {
      test('cannot set level to `null`', () {
        final logger = Logger('logger');

        expect(() => logger.level = null, throwsArgumentError);
      });

      test('inherits parent logger severity level (HIERARCHY)', () {
        final e = Logger.getLogger('e');

        expect(e.level, Logger.root.level);

        e.level = Level.all;
        final f = Logger.getLogger('e.f');

        expect(f.level, same(e.level));

        f.level = Level.warning;
        final g = Logger.getLogger('e.f.g');

        expect(g.level, same(f.level));
      });
    });
  });
}
