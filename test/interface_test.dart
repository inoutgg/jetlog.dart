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
      test('Works correctly', () {
        final handler = MemoryHandler();
        final logger = Logger.detached()
          ..handler = handler
          ..level = Level.all;

        logger.log(Level.danger, '');
        logger.log(Level.danger, '');
        logger.log(Level.danger, '');
        logger.log(Level.danger, '');
        logger.log(Level.danger, '');
        logger.log(Level.danger, '');
        logger.log(Level.danger, '');
        logger.log(Level.danger, '');

        expect(handler.records, hasLength(8));
      });

      test('Correctly sets records fields', () {
        final handler = MemoryHandler();
        final logger = Logger.detached()..handler = handler;

        logger.log(Level.info, 'test');

        final records = handler.records;

        expect(records, hasLength(1));

        final record = records.elementAt(0);

        expect(record.name, isNull);
        expect(record.level, same(Level.info));
        expect(record.message, 'test');
        expect(record.time, isNotNull);
        expect(record.fields, isNull);
      });

      test('Filters base on severity level', () {
        final handler = MemoryHandler();
        final logger = Logger.detached()
          ..handler = handler
          ..level = Level.warning;

        logger.log(Level.debug, 'debug');
        logger.log(Level.info, 'info');
        logger.log(Level.warning, 'warning');
        logger.log(Level.danger, 'danger');
        logger.log(Level.fatal, 'fatal');

        final records = handler.records;

        expect(records, hasLength(3));
        expect(records.elementAt(0).level, same(Level.warning));
        expect(records.elementAt(1).level, same(Level.danger));
        expect(records.elementAt(2).level, same(Level.fatal));
      });

      test('Filters base on filters', () {
        final handler = MemoryHandler();
        final logger = Logger.detached()
          ..handler = handler
          ..addFilter(_TestFilter())
          ..level = Level.all;

        logger
          ..debug('debug')
          ..trace('trace')
          ..info('info')
          ..warning('warning')
          ..danger('danger')
          ..fatal('fatal');

        expect(handler.records, hasLength(1));
        expect(handler.records.elementAt(0).level, same(Level.danger));
      });

      test('Emits logs in order', () {
        final handler = MemoryHandler();
        final logger = Logger.detached()
          ..handler = handler
          ..level = Level.all;

        logger.info('1');
        logger.warning('2');
        logger.debug('3');
        logger.info('4');
        logger.fatal('5');
        logger.danger('6');
        logger.debug('7');

        final records = handler.records;

        expect(records, hasLength(7));
        expect(records.elementAt(0).message, '1');
        expect(records.elementAt(1).message, '2');
        expect(records.elementAt(2).message, '3');
        expect(records.elementAt(3).message, '4');
        expect(records.elementAt(4).message, '5');
        expect(records.elementAt(5).message, '6');
        expect(records.elementAt(6).message, '7');
      });

      test('Delegates logs down to parent (HIERARCHY)', () {
        final abcHandler = MemoryHandler();
        final abHandler = MemoryHandler();
        final aHandler = MemoryHandler();
        final cHandler = MemoryHandler();
        final abc = Logger.getLogger('a.b.c')..handler = abcHandler;
        Logger.getLogger('a.b').handler = abHandler;
        Logger.getLogger('a').handler = aHandler;
        Logger.getLogger('c').handler = cHandler;

        abc.log(Level.info, 'Log');

        // stream is async, so wait until next event-loop tick.
        // TODO: rewrite using `test` api.
        expect(abcHandler.records, hasLength(1));
        expect(abHandler.records, hasLength(1));
        expect(aHandler.records, hasLength(1));
        expect(cHandler.records, hasLength(0));
        expect(abHandler.records.toList()[0].message, 'Log');
        expect(abcHandler.records.toList()[0].message, 'Log');
        expect(aHandler.records.toList()[0].message, 'Log');
      });

      test(
          'Filters delegated logs passed down to parents based on parents\' level'
          ' (HIERARCHY)', () {
        final abcHandler = MemoryHandler();
        final abHandler = MemoryHandler();
        final aHandler = MemoryHandler();
        final abc = Logger.getLogger('a.b.c')
          ..handler = abcHandler
          ..level = Level.all;
        Logger.getLogger('a.b')
          ..handler = abHandler
          ..level = Level.warning;
        Logger.getLogger('a')
          ..handler = aHandler
          ..level = Level.danger;

        abc
          ..log(Level.info, 'Log')
          ..log(Level.warning, 'Log')
          ..log(Level.danger, 'Log')
          ..log(Level.fatal, 'Log');

        // stream is async, so wait until next event-loop tick.
        // TODO: rewrite using `test` api.
        final abcRecords = abcHandler.records;
        final abRecords = abHandler.records;
        final aRecords = aHandler.records;

        expect(abcRecords, hasLength(4));
        expect(abRecords, hasLength(3));
        expect(aRecords, hasLength(2));
      });
    });

    group('#debug', () {
      test('Emits with corresponding severity level', () {
        final handler = MemoryHandler();
        final logger = Logger.detached()
          ..handler = handler
          ..level = Level.all;

        logger.debug('Message');

        expect(handler.records, hasLength(1));
        expect(handler.records.elementAt(0).level, same(Level.debug));
      });
    });

    group('#info', () {
      test('Emits with corresponding severity level', () {
        final handler = MemoryHandler();
        final logger = Logger.detached()
          ..handler = handler
          ..level = Level.all;

        logger.info('Message');

        expect(handler.records, hasLength(1));
        expect(handler.records.elementAt(0).level, same(Level.info));
      });
    });

    group('#warning', () {
      test('Emits with corresponding severity level', () {
        final handler = MemoryHandler();
        final logger = Logger.detached()
          ..handler = handler
          ..level = Level.all;

        logger.warning('Message');

        expect(handler.records, hasLength(1));
        expect(handler.records.elementAt(0).level, same(Level.warning));
      });
    });

    group('#danger', () {
      test('Emits with corresponding severity level', () {
        final handler = MemoryHandler();
        final logger = Logger.detached()
          ..handler = handler
          ..level = Level.all;

        logger.danger('Message');

        expect(handler.records, hasLength(1));
        expect(handler.records.elementAt(0).level, same(Level.danger));
      });
    });

    group('#fatal', () {
      test('Emits with corresponding severity level', () {
        final handler = MemoryHandler();
        final logger = Logger.detached()
          ..handler = handler
          ..level = Level.all;

        logger.fatal('Message');

        expect(handler.records, hasLength(1));
        expect(handler.records.elementAt(0).level, same(Level.fatal));
      });
    });

    group('#bind', () {
      test('Always returns a new logging context', () {
        final logger = Logger.detached();

        final context1 = logger.bind();
        final context2 = logger.bind();

        expect(context1, isNot(same(context2)));
      });

      test(
          'Logs emitted on logging context deletegated down to parent (HIERARCHY)',
          () {
        final abcHandler = MemoryHandler();
        final abHandler = MemoryHandler();
        final aHandler = MemoryHandler();
        final abc = Logger.getLogger('a.b.c')
          ..handler = abcHandler
          ..level = Level.info;
        Logger.getLogger('a.b')
          ..handler = abHandler
          ..level = Level.warning;
        Logger.getLogger('a')
          ..handler = aHandler
          ..level = Level.danger;

        final context = abc.bind();

        context
          ..info('ABC')
          ..danger('ABC')
          ..warning('ABC')
          ..fatal('ABC');

        final abcRecords = abcHandler.records;
        final abRecords = abHandler.records;
        final aRecords = aHandler.records;

        expect(abcRecords, hasLength(4));
        expect(abRecords, hasLength(3));
        expect(aRecords, hasLength(2));
      });

      test('Respects loggers\' severity level threshold', () {
        final handler = MemoryHandler();
        final logger = Logger.detached()
          ..level = Level.warning
          ..handler = handler;

        final context = logger.bind();

        context.info('info');
        context.fatal('fatal');
        context.debug('debug');
        context.warning('warning');

        final records = handler.records;

        expect(records, hasLength(2));
        expect(records.elementAt(0).message, 'fatal');
        expect(records.elementAt(1).message, 'warning');
      });

      test('correctly binds provided values to the logging context', () {
        final handler = MemoryHandler();
        final logger = Logger.detached()..handler = handler;

        final context1 = logger.bind([
          const Str('string', 'string1'),
          const Dur('duration', Duration.zero)
        ]);

        context1.info('Message');

        final records = handler.records;

        expect(records, hasLength(1));

        final record = records.elementAt(0);
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

      test('supports custom fields', () {
        final handler = MemoryHandler();
        final logger = Logger.detached()..handler = handler;

        final context = logger.bind([
          const Field<int>(
              name: 'custom-field', value: 0x10, kind: FieldKind(0x100))
        ]);

        context.info('Test');

        final records = handler.records;
        final record = records.elementAt(0);
        final field =
            record.fields.firstWhere((field) => field.name == 'custom-field');

        expect(field.name, 'custom-field');
        expect(field.value, 0x10);
      });

      test('extends previous context', () {
        final handler = MemoryHandler();
        final logger = Logger.detached()
          ..handler = handler
          ..level = Level.info;

        final context1 = logger.bind([
          const Dur('dur', Duration.zero),
          const Str('str', 'str'),
        ]);

        context1.info('info');

        final context2 = context1.bind([
          const Int('int', 0x10),
          const Double('double', 0.3),
        ]);

        context2.info('info');

        final records = handler.records;

        expect(records, hasLength(2));
        expect(records.elementAt(0).fields, hasLength(2));
        expect(records.elementAt(1).fields, hasLength(4));
        expect(
            records
                .elementAt(0)
                .fields
                .firstWhere((f) => f.name == 'dur')
                .value,
            Duration.zero);
        expect(
            records
                .elementAt(1)
                .fields
                .firstWhere((f) => f.name == 'int')
                .value,
            0x10);
      });
    });

    group('#trace', () {
      test('returns a non-null tracer', () {
        final logger = Logger.detached();
        final trace = logger.trace('Trace');

        expect(trace, isNotNull);
      });

      test('correctly emits logs', () {
        final handler = MemoryHandler();
        final logger = Logger.detached()
          ..level = Level.all
          ..handler = handler;

        final tracer = logger.trace('start trace');
        tracer.stop('stop trace');

        final records = handler.records;

        expect(records, hasLength(2));
        expect(records.elementAt(0).message, 'start trace');
        expect(records.elementAt(1).message, 'stop trace');
      });

      test('emits with correct severity level', () {
        final handler = MemoryHandler();
        final logger = Logger.detached()
          ..level = Level.all
          ..handler = handler;

        logger.trace('start').stop('stop');

        final records = handler.records;

        expect(records, hasLength(2));
        expect(records.elementAt(0).level, same(Level.trace));
        expect(records.elementAt(1).level, same(Level.trace));
      });

      test('tracks start time and duration', () {
        final handler = MemoryHandler();
        final logger = Logger.detached()
          ..level = Level.all
          ..handler = handler;

        logger.trace('start').stop('stop');

        final records = handler.records;

        expect(records, hasLength(2));
        expect(
            records
                .elementAt(0)
                .fields
                .firstWhere((f) => f.name == 'start')
                .value,
            isNotNull);
        expect(
            records
                .elementAt(1)
                .fields
                .firstWhere((f) => f.name == 'duration')
                .value,
            isNotNull);
      });
    });
  });
}
