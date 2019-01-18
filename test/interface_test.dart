import 'dart:async' show Future;
import 'package:test/test.dart';
import 'package:structlog/structlog.dart';
import 'package:structlog/handlers.dart' show MemoryHandler;

class _TestFilter extends Filter {
  @override
  bool filter(Record record) => record.level == Level.danger;
}

void main() {
  group('Interface', () {
    group('#log', () {
      test('Works correctly', () async {
        final handler = MemoryHandler();
        final logger = Logger()
          ..addHandler(handler)
          ..level = Level.all;

        logger.log(Level.danger, '');
        logger.log(Level.danger, '');
        logger.log(Level.danger, '');
        logger.log(Level.danger, '');
        logger.log(Level.danger, '');
        logger.log(Level.danger, '');
        logger.log(Level.danger, '');
        logger.log(Level.danger, '');

        await Future<void>.delayed(Duration.zero, () {
          expect(handler.records, hasLength(8));
        });
      });

      test('Correctly sets records fields', () async {
        final handler = MemoryHandler();
        final logger = Logger()..addHandler(handler);

        logger.log(Level.info, 'test');

        await Future<void>.delayed(Duration.zero, () {
          final records = handler.records.toList();

          expect(records, hasLength(1));

          final record = records[0];

          expect(record.name, isNull);
          expect(record.level, same(Level.info));
          expect(record.message, 'test');
          expect(record.time, isNotNull);
          expect(record.fields, isNull);
        });
      });

      test('Filters base on severity level', () async {
        final handler = MemoryHandler();
        final logger = Logger()
          ..addHandler(handler)
          ..level = Level.warning;

        logger.log(Level.debug, 'debug');
        logger.log(Level.info, 'info');
        logger.log(Level.warning, 'warning');
        logger.log(Level.danger, 'danger');
        logger.log(Level.fatal, 'fatal');

        // stream is async, so wait until next event-loop tick.
        // TODO: rewrite `test` api
        await Future<void>.delayed(Duration.zero, () {
          final records = handler.records.toList();

          expect(records, hasLength(3));
          expect(records[0].level, same(Level.warning));
          expect(records[1].level, same(Level.danger));
          expect(records[2].level, same(Level.fatal));
        });
      });

      test('Filters base on filters', () async {
        final handler = MemoryHandler();
        final logger = Logger()
          ..addHandler(handler)
          ..addFilter(_TestFilter())
          ..level = Level.all;

        logger.debug('debug');
        logger.trace('trace');
        logger.info('info');
        logger.warning('warning');
        logger.danger('danger');
        logger.fatal('fatal');

        // stream is async, so wait until next event-loop tick.
        // TODO: rewrite `test` api
        await Future<void>.delayed(Duration.zero, () {
          final records = handler.records.toList();

          expect(records, hasLength(1));
          expect(records[0].level, same(Level.danger));
        });
      });
    });

    test('Emits logs in order', () async {
      final handler = MemoryHandler();
      final logger = Logger()
        ..addHandler(handler)
        ..level = Level.all;

      logger.info('1');
      logger.warning('2');
      logger.debug('3');
      logger.info('4');
      logger.fatal('5');
      logger.danger('6');
      logger.debug('7');

      // stream is async, so wait until next event-loop tick.
      // TODO: rewrite `test` api
      await Future<void>.delayed(Duration.zero, () {
        final records = handler.records.toList();

        expect(records, hasLength(7));
        expect(records[0].message, '1');
        expect(records[1].message, '2');
        expect(records[2].message, '3');
        expect(records[3].message, '4');
        expect(records[4].message, '5');
        expect(records[5].message, '6');
        expect(records[6].message, '7');
      });
    });

    test('Delegates logs down to parent (HIERARCHY)', () async {
      final abcHandler = MemoryHandler();
      final abHandler = MemoryHandler();
      final aHandler = MemoryHandler();
      final cHandler = MemoryHandler();
      final abc = Logger.getLogger('a.b.c')..addHandler(abcHandler);
      final ab = Logger.getLogger('a.b')..addHandler(abHandler);
      final a = Logger.getLogger('a')..addHandler(aHandler);
      final c = Logger.getLogger('c')..addHandler(cHandler);

      abc.log(Level.info, 'Log');

      // stream is async, so wait until next event-loop tick.
      // TODO: rewrite using `test` api.
      await Future<void>.delayed(Duration.zero, () {
        expect(abcHandler.records, hasLength(1));
        expect(abHandler.records, hasLength(1));
        expect(aHandler.records, hasLength(1));
        expect(cHandler.records, hasLength(0));
        expect(abHandler.records.toList()[0].message, 'Log');
        expect(abcHandler.records.toList()[0].message, 'Log');
        expect(aHandler.records.toList()[0].message, 'Log');
      });
    });

    test(
        'Filters delegated logs passed down to parents based on parents\' level'
        ' (HIERARCHY)', () async {
      final abcHandler = MemoryHandler();
      final abHandler = MemoryHandler();
      final aHandler = MemoryHandler();
      final abc = Logger.getLogger('a.b.c')
        ..addHandler(abcHandler)
        ..level = Level.all;
      Logger.getLogger('a.b')
        ..addHandler(abHandler)
        ..level = Level.warning;
      Logger.getLogger('a')
        ..addHandler(aHandler)
        ..level = Level.danger;

      abc
        ..log(Level.info, 'Log')
        ..log(Level.warning, 'Log')
        ..log(Level.danger, 'Log')
        ..log(Level.fatal, 'Log');

      // stream is async, so wait until next event-loop tick.
      // TODO: rewrite using `test` api.
      await Future<void>.delayed(Duration.zero, () {
        final abcRecords = abcHandler.records.toList();
        final abRecords = abHandler.records.toList();
        final aRecords = aHandler.records.toList();

        expect(abcRecords, hasLength(4));
        expect(abRecords, hasLength(3));
        expect(aRecords, hasLength(2));
      });
    });
  });

  group('#debug', () {
    test('Emits with corresponding severity level', () async {
      final handler = MemoryHandler();
      final logger = Logger()
        ..addHandler(handler)
        ..level = Level.all;

      logger.debug('Message');

      await Future<void>.delayed(Duration.zero, () {
        expect(handler.records, hasLength(1));
        expect(handler.records.toList()[0].level, same(Level.debug));
      });
    });
  });

  group('#info', () {
    test('Emits with corresponding severity level', () async {
      final handler = MemoryHandler();
      final logger = Logger()
        ..addHandler(handler)
        ..level = Level.all;

      logger.info('Message');

      await Future<void>.delayed(Duration.zero, () {
        expect(handler.records, hasLength(1));
        expect(handler.records.toList()[0].level, same(Level.info));
      });
    });
  });

  group('#warning', () {
    test('Emits with corresponding severity level', () async {
      final handler = MemoryHandler();
      final logger = Logger()
        ..addHandler(handler)
        ..level = Level.all;

      logger.warning('Message');

      await Future<void>.delayed(Duration.zero, () {
        expect(handler.records, hasLength(1));
        expect(handler.records.toList()[0].level, same(Level.warning));
      });
    });
  });

  group('#danger', () {
    test('Emits with corresponding severity level', () async {
      final handler = MemoryHandler();
      final logger = Logger()
        ..addHandler(handler)
        ..level = Level.all;

      logger.danger('Message');

      await Future<void>.delayed(Duration.zero, () {
        expect(handler.records, hasLength(1));
        expect(handler.records.toList()[0].level, same(Level.danger));
      });
    });
  });

  group('#fatal', () {
    test('Emits with corresponding severity level', () async {
      final handler = MemoryHandler();
      final logger = Logger()
        ..addHandler(handler)
        ..level = Level.all;

      logger.fatal('Message');

      await Future<void>.delayed(Duration.zero, () {
        expect(handler.records, hasLength(1));
        expect(handler.records.toList()[0].level, same(Level.fatal));
      });
    });
  });

  group('#bind', () {
    test('Always returns a new logging context', () {
      final logger = Logger();

      final context1 = logger.bind();
      final context2 = logger.bind();

      expect(context1, isNot(same(context2)));
    });

    test(
        'Logs emitted on logging context deletegated down to parent (HIERARCHY)',
        () async {
      final abcHandler = MemoryHandler();
      final abHandler = MemoryHandler();
      final aHandler = MemoryHandler();
      final abc = Logger.getLogger('a.b.c')
        ..addHandler(abcHandler)
        ..level = Level.info;
      Logger.getLogger('a.b')
        ..addHandler(abHandler)
        ..level = Level.warning;
      Logger.getLogger('a')
        ..addHandler(aHandler)
        ..level = Level.danger;

      final context = abc.bind();

      context
        ..info('ABC')
        ..danger('ABC')
        ..warning('ABC')
        ..fatal('ABC');

      await Future<void>.delayed(Duration.zero, () {
        final abcRecords = abcHandler.records.toList();
        final abRecords = abHandler.records.toList();
        final aRecords = aHandler.records.toList();

        expect(abcRecords, hasLength(4));
        expect(abRecords, hasLength(3));
        expect(aRecords, hasLength(2));
      });
    });

    test('correctly binds provided values to the logging context', () async {
      final handler = MemoryHandler();
      final logger = Logger()..addHandler(handler);

      final context1 = logger.bind([
        const Str('string', 'string1'),
        const Dur('duration', Duration.zero)
      ]);

      context1.info('Message');

      await Future<void>.delayed(Duration.zero, () {
        final records = handler.records.toList();

        expect(records, hasLength(1));

        final record = records[0];
        final fields = record.fields.toList();
        final strField = fields.firstWhere((field) => field.name == 'string');
        final durField = fields.firstWhere((field) => field.name == 'duration');

        expect(strField, isNotNull);
        expect(strField.name, 'string');
        expect(strField.value, 'string1');
        expect(durField, isNotNull);
        expect(durField.name, 'duration');
        expect(durField.value, Duration.zero);
      });
    });

    test('supports custom fields', () async {
      final handler = MemoryHandler();
      final logger = Logger()..addHandler(handler);

      final context = logger.bind([
        const Field<int>(
            name: 'custom-field', value: 0x10, kind: FieldKind(0x100))
      ]);

      context.info('Test');

      await Future<void>.delayed(Duration.zero, () {
        final records = handler.records.toList();
        final record = records[0];
        final field =
            record.fields.firstWhere((field) => field.name == 'custom-field');

        expect(field.name, 'custom-field');
        expect(field.value, 0x10);
      });
    });
  });
}
