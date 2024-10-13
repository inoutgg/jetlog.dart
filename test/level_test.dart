import 'package:jetlog/src/level.dart';
import 'package:test/test.dart';

void main() {
  group('Level', () {
    // stolen from https://github.com/dart-lang/logging/blob/master/test/logging_test.dart#L13
    test('level comparison is a valid comparator', () {
      const level1 = Level(name: 'NOT_REAL1', value: 253);
      expect(level1 == level1, isTrue);
      expect(level1 <= level1, isTrue);
      expect(level1 >= level1, isTrue);
      expect(level1 < level1, isFalse);
      expect(level1 > level1, isFalse);

      const level2 = Level(name: 'NOT_REAL2', value: 455);
      expect(level1 <= level2, isTrue);
      expect(level1 < level2, isTrue);
      expect(level2 >= level1, isTrue);
      expect(level2 > level1, isTrue);

      const level3 = Level(name: 'NOT_REAL3', value: 253);
      expect(level1, isNot(same(level3))); // different instances
      expect(level1, equals(level3)); // same value.
    });

    test('Builtin levels to be sorted by severity', () {
      expect(Level.all < Level.debug, isTrue);
      expect(Level.debug < Level.info, isTrue);
      expect(Level.info < Level.warn, isTrue);
      expect(Level.warn < Level.error, isTrue);
      expect(Level.error < Level.fatal, isTrue);
      expect(Level.fatal < Level.off, isTrue);
    });

    test('To be comparable', () {
      final sortedLevels = <Level>[
        Level.debug,
        Level.info,
        Level.warn,
        Level.error,
        Level.fatal,
      ];

      final levels = <Level>[
        Level.error,
        Level.info,
        Level.fatal,
        Level.debug,
        Level.warn,
      ];

      // before
      expect(levels, isNot(orderedEquals(sortedLevels)));

      levels.sort();

      // after
      expect(levels, orderedEquals(sortedLevels));
    });

    test('To be hashable', () {
      const customLevel = Level(name: 'CUSTOM_LEVEL', value: 0xff);
      final levels = <Level, int>{
        Level.debug: 1,
        Level.info: 2,
        Level.warn: 3,
        Level.error: 4,
        Level.fatal: 5,
        customLevel: 6,
      };

      expect(levels[Level.debug], 1);
      expect(levels[Level.info], 2);
      expect(levels[Level.warn], 3);
      expect(levels[Level.error], 4);
      expect(levels[Level.fatal], 5);
      expect(levels[customLevel], 6);
    });

    test('returns correct string representation', () {
      const level = Level(name: 'CUSTOM_LEVEL', value: 0xf);

      expect(Level.info.toString(), 'Level(name=INFO)');
      expect(Level.all.toString(), 'Level(name=<ALL>)');
      expect(level.toString(), 'Level(name=CUSTOM_LEVEL)');
    });
  });
}
