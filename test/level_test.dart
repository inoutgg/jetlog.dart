import 'package:test/test.dart';
import 'package:structlog/src/level.dart';

void main() {
  group('Level', () {
    test('Builtin levels to be sorted by severity', () {
      expect(Level.all < Level.trace, isTrue);
      expect(Level.debug < Level.trace, isTrue);
      expect(Level.trace < Level.info, isTrue);
      expect(Level.info < Level.warning, isTrue);
      expect(Level.warning < Level.danger, isTrue);
      expect(Level.danger < Level.fatal, isTrue);
      expect(Level.fatal < Level.off, isTrue);
    });

    test('To be comparable', () {
      final sortedLevels = <Level>[
        Level.debug,
        Level.trace,
        Level.info,
        Level.warning,
        Level.danger,
        Level.fatal,
      ];

      final levels = <Level>[
        Level.trace,
        Level.danger,
        Level.info,
        Level.fatal,
        Level.debug,
        Level.warning,
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
        Level.debug: 0,
        Level.trace: 1,
        Level.info: 2,
        Level.warning: 3,
        Level.danger: 4,
        Level.fatal: 5,
        customLevel: 6,
      };

      expect(levels[Level.debug], 0);
      expect(levels[Level.trace], 1);
      expect(levels[Level.info], 2);
      expect(levels[Level.warning], 3);
      expect(levels[Level.danger], 4);
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
