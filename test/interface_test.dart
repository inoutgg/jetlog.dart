import 'dart:async';

import 'package:jetlog/formatters.dart';
import 'package:jetlog/handlers.dart';
import 'package:jetlog/jetlog.dart';
import 'package:test/test.dart';

Future<void> later(void action()) => Future.delayed(Duration.zero, action);

bool _testFilter(Record record) => record.level == Level.danger;

class CustomObject implements Loggable {
  @override
  Iterable<Field> toFields() => {
        Str.lazy('LazyStr', () => 'logger'),
        const Str('Str', 'string'),
      };
}

const Level customLevel = Level(name: 'custom', value: 0x600);

extension CustomLevelLog on Interface {
  void customLog(String message) => log(customLevel, message);
}

void main() {
  group('Interface', () {
    group('#log', () {
      test('Works correctly', () async {
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

        await later(() {
          final records = handler.records;

          expect(records, hasLength(8));
        });
      });

      test('Correctly sets records fields', () async {
        final handler = MemoryHandler();
        final logger = Logger.detached()..handler = handler;

        logger.log(Level.info, 'test');

        await later(() {
          final records = handler.records;

          final record = records.elementAt(0);

          expect(record.name, isNull);
          expect(record.level, same(Level.info));
          expect(record.message, 'test');
          expect(record.timestamp, isNotNull);
          expect(record.fields, isNull);
        });
      });

      test('Filters base on severity level', () async {
        final handler = MemoryHandler();
        final logger = Logger.detached()
          ..handler = handler
          ..level = Level.warning;

        logger
          ..log(Level.debug, 'debug')
          ..log(Level.info, 'info')
          ..log(Level.warning, 'warning')
          ..log(Level.danger, 'danger')
          ..log(Level.fatal, 'fatal');

        await later(() {
          final records = handler.records;

          expect(records, hasLength(3));
          expect(records.elementAt(0).level, same(Level.warning));
          expect(records.elementAt(1).level, same(Level.danger));
          expect(records.elementAt(2).level, same(Level.fatal));
        });
      });

      test('Filters base on filters', () async {
        final handler = MemoryHandler();
        final logger = Logger.detached()
          ..handler = handler
          ..filter = _testFilter
          ..level = Level.all;

        logger
          ..debug('debug')
          ..trace('trace')
          ..info('info')
          ..warning('warning')
          ..danger('danger')
          ..fatal('fatal');

        await later(() {
          final records = handler.records;

          expect(records, hasLength(1));
          expect(records.elementAt(0).level, same(Level.danger));
        });
      });

      test('Emits logs in order', () async {
        final handler = MemoryHandler();
        final logger = Logger.detached()
          ..handler = handler
          ..level = Level.all;

        logger
          ..info('1')
          ..warning('2')
          ..debug('3')
          ..info('4')
          ..fatal('5')
          ..danger('6')
          ..debug('7');

        await later(() {
          final records = handler.records;

          expect(records.elementAt(0).message, '1');
          expect(records.elementAt(1).message, '2');
          expect(records.elementAt(2).message, '3');
          expect(records.elementAt(3).message, '4');
          expect(records.elementAt(4).message, '5');
          expect(records.elementAt(5).message, '6');
          expect(records.elementAt(6).message, '7');
        });
      });

      test('Delegates logs down to parent (HIERARCHY)', () async {
        final abcHandler = MemoryHandler();
        final abHandler = MemoryHandler();
        final aHandler = MemoryHandler();
        final abc = Logger.getLogger('a.b.c')..handler = abcHandler;
        Logger.getLogger('a.b').handler = abHandler;
        Logger.getLogger('a').handler = aHandler;

        abc.log(Level.info, 'Log');

        await later(() {
          final abcRecords = abcHandler.records;
          final abRecords = abHandler.records;
          final aRecords = aHandler.records;

          expect(abcRecords, hasLength(1));
          expect(abRecords, hasLength(1));
          expect(aRecords, hasLength(1));
          expect(abcRecords.elementAt(0).message, 'Log');
          expect(abRecords.elementAt(0).message, 'Log');
          expect(aRecords.elementAt(0).message, 'Log');
        });
      });

      test(
          'Filters delegated logs passed down to parents based on parents\' level'
          ' (HIERARCHY)', () async {
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

        await later(() {
          final abcRecords = abcHandler.records;
          final abRecords = abHandler.records;
          final aRecords = aHandler.records;

          expect(abcRecords, hasLength(4));
          expect(abRecords, hasLength(3));
          expect(aRecords, hasLength(2));
        });
      });
    });

    group('#debug', () {
      test('Emits with corresponding severity level', () async {
        final handler = MemoryHandler();
        final logger = Logger.detached()
          ..handler = handler
          ..level = Level.all;

        logger.debug('Message');

        await later(() {
          final records = handler.records;

          expect(records.elementAt(0).level, same(Level.debug));
        });
      });
    });

    group('#info', () {
      test('Emits with corresponding severity level', () async {
        final handler = MemoryHandler();
        final logger = Logger.detached()
          ..handler = handler
          ..level = Level.all;

        logger.info('Message');

        await later(() {
          final records = handler.records;

          expect(records.elementAt(0).level, same(Level.info));
        });
      });
    });

    group('#warning', () {
      test('Emits with corresponding severity level', () async {
        final handler = MemoryHandler();
        final logger = Logger.detached()
          ..handler = handler
          ..level = Level.all;

        logger.warning('Message');

        await later(() {
          final records = handler.records;

          expect(records.elementAt(0).level, same(Level.warning));
        });
      });
    });

    group('#danger', () {
      test('Emits with corresponding severity level', () async {
        final handler = MemoryHandler();
        final logger = Logger.detached()
          ..handler = handler
          ..level = Level.all;

        logger.danger('Message');

        await later(() {
          final records = handler.records;

          expect(records.elementAt(0).level, same(Level.danger));
        });
      });
    });

    group('#fatal', () {
      test('Emits with corresponding severity level', () async {
        final handler = MemoryHandler();
        final logger = Logger.detached()
          ..handler = handler
          ..level = Level.all;

        logger.fatal('Message');

        await later(() {
          final records = handler.records;

          expect(records.elementAt(0).level, same(Level.fatal));
        });
      });
    });

    group('#bind', () {
      test('Always returns a new logging context', () async {
        final logger = Logger.detached();

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

        await later(() {
          final abcRecords = abcHandler.records;
          final abRecords = abHandler.records;
          final aRecords = aHandler.records;

          expect(abcRecords, hasLength(4));
          expect(abRecords, hasLength(3));
          expect(aRecords, hasLength(2));
        });
      });

      test('Respects loggers\' severity level threshold', () async {
        final handler = MemoryHandler();
        final logger = Logger.detached()
          ..level = Level.warning
          ..handler = handler;

        final context = logger.bind();

        context.info('info');
        context.fatal('fatal');
        context.debug('debug');
        context.warning('warning');

        await later(() {
          final records = handler.records;

          expect(records, hasLength(2));
          expect(records.elementAt(0).message, 'fatal');
          expect(records.elementAt(1).message, 'warning');
        });
      });

      test('correctly binds provided values to the logging context', () async {
        final handler = MemoryHandler();
        final logger = Logger.detached()..handler = handler;

        final context1 = logger.bind([
          const Str('string', 'string1'),
          const Dur('duration', Duration.zero)
        ]);

        context1.info('Message');

        await later(() {
          final records = handler.records;

          final record = records.elementAt(0);
          final fields = record.fields?.toList();
          final strField =
              fields?.firstWhere((field) => field.name == 'string');
          final durField =
              fields?.firstWhere((field) => field.name == 'duration');

          expect(strField, isNotNull);
          expect(strField?.name, 'string');
          expect(strField?.value, 'string1');
          expect(durField, isNotNull);
          expect(durField?.name, 'duration');
          expect(durField?.value, Duration.zero);
        });
      });

      test('supports custom fields', () async {
        final handler = MemoryHandler();
        final logger = Logger.detached()..handler = handler;

        final context = logger.bind({
          const Field<int>(
              name: 'custom-field', value: 0x10, kind: FieldKind(0x100)),
        });

        context.info('Test');

        await later(() {
          final records = handler.records;

          final record = records.elementAt(0);
          final field = record.fields
              ?.firstWhere((field) => field.name == 'custom-field');

          expect(field?.name, 'custom-field');
          expect(field?.value, 0x10);
        });
      });

      test('correctly evaluates lazy fields', () {
        final records = <String>[];

        runZoned<void>(() async {
          final logger = Logger.detached()
            ..handler = ConsoleHandler(
                formatter: TextFormatter(
                    (name, timestamp, level, message, fields) => '$fields'));
          final context = logger.bind({
            const Bool('StaticBool', false),
            Bool.lazy('LazyBool', () => true),
            Double.lazy('LazyDouble', () => 0.2),
            DTM.lazy(
                'LazyDTM', () => DateTime.parse('2019-10-07 15:11:39.373703')),
            Dur.lazy('LazyDur', () => Duration.zero),
            Int.lazy('LazyInt', () => 1),
            Num.lazy('LazyNum', () => 123.1),
            Obj.lazy('LazyObj', () => CustomObject()),
            Str.lazy('LazyStr', () {
              print('LazyString print!');

              return 'str';
            }),
          });

          expect(records.length, equals(0));

          context.info('Test');

          await later(() {
            expect(records.length, equals(2));
            expect(records.first, 'LazyString print!');
            expect(
                records.last,
                'StaticBool=false '
                'LazyBool=true '
                'LazyDouble=0.2 '
                'LazyDTM=2019-10-07 15:11:39.373703 '
                'LazyDur=0:00:00.000000 '
                'LazyInt=1 '
                'LazyNum=123.1 '
                'LazyObj.LazyStr=logger '
                'LazyObj.Str=string '
                'LazyStr=str');
          });
        },
            zoneSpecification: ZoneSpecification(
                print: (self, parent, zone, line) => records.add(line)));
      });

      group('Any', () {
        test('correctly handles known "static" types', () async {
          final handler = MemoryHandler();
          final logger = Logger.detached()..handler = handler;
          final dt = DateTime.now();

          final context = logger.bind({
            Any('f1', true),
            Any('f2', 1.0),
            Any('f3', dt),
            Any('f4', Duration.zero),
            Any('f5', 0x1),
            Any('f6', num.parse('1')),
            Any('f7', 'string')
          });

          context.info('Test');

          await later(() {
            final record = handler.records.first;

            expect(
                record.fields?.toList(),
                orderedEquals(<Field>[
                  const Bool('f1', true),
                  const Double('f2', 1.0),
                  DTM('f3', dt),
                  const Dur('f4', Duration.zero),
                  const Int('f5', 0x1),
                  Num('f6', num.parse('1')),
                  const Str('f7', 'string'),
                ]));
          });
        });

        test('correctly evaluates "lazy" types', () async {
          final records = StreamController<String>();

          runZoned<void>(() async {
            final logger = Logger.detached()
              ..handler = ConsoleHandler(
                  formatter: TextFormatter(
                      (name, timestamp, level, message, fields) => '$fields'));
            final dt = DateTime.now();

            final context = logger.bind({
              Any.lazy('f1', () => true),
              Any.lazy('f2', () => 1.0),
              Any.lazy('f3', () => dt),
              Any.lazy('f4', () => Duration.zero),
              Any.lazy('f5', () => 0x1),
              Any.lazy('f6', () => num.parse('1')),
              Any.lazy('f7', () => 'string')
            });

            context.info('Test');

            await expectLater(
                records.stream,
                emits('f1=true '
                    'f2=1.0 '
                    'f3=${dt.toString()} '
                    'f4=${Duration.zero} '
                    'f5=1 '
                    'f6=1 '
                    'f7=string'));


            await records.close();
          },
              zoneSpecification: ZoneSpecification(
                  print: (self, parent, zone, line) => records.add(line)));
        });
      });

      test('extends previous context', () async {
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

        await later(() {
          final records = handler.records;

          expect(records.elementAt(0).fields, hasLength(2));
          expect(records.elementAt(1).fields, hasLength(4));
          expect(
              records
                  .elementAt(0)
                  .fields
                  ?.firstWhere((f) => f.name == 'dur')
                  .value,
              Duration.zero);
          expect(
              records
                  .elementAt(1)
                  .fields
                  ?.firstWhere((f) => f.name == 'int')
                  .value,
              0x10);
        });
      });
    });

    group('#trace', () {
      test('returns a non-null tracer', () async {
        final logger = Logger.detached();
        final trace = logger.trace('Trace');

        expect(trace, isNotNull);
      });

      test('correctly emits logs', () async {
        final handler = MemoryHandler();
        final logger = Logger.detached()
          ..level = Level.all
          ..handler = handler;

        final tracer = logger.trace('start trace');
        tracer.stop('stop trace');

        await later(() {
          final records = handler.records;
          expect(records.elementAt(0).message, 'start trace');
          expect(records.elementAt(1).message, 'stop trace');
        });
      });

      test('emits with correct severity level', () async {
        final handler = MemoryHandler();
        final logger = Logger.detached()
          ..level = Level.all
          ..handler = handler;

        logger.trace('start').stop('stop');

        await later(() {
          final records = handler.records;
          expect(records.elementAt(0).level, same(Level.debug));
          expect(records.elementAt(1).level, same(Level.debug));
        });
      });

      test('tracks start time and duration', () async {
        final handler = MemoryHandler();
        final logger = Logger.detached()
          ..level = Level.all
          ..handler = handler;

        logger.trace('start').stop('stop');

        await later(() {
          final records = handler.records;
          expect(
              records
                  .elementAt(0)
                  .fields
                  ?.firstWhere((f) => f.name == 'start')
                  .value,
              isNotNull);
          expect(
              records
                  .elementAt(1)
                  .fields
                  ?.firstWhere((f) => f.name == 'duration')
                  .value,
              isNotNull);
        });
      });

      test('accepts custom severity level', () async {
        final handler = MemoryHandler();
        final logger = Logger.detached()
          ..handler = handler
          ..level = Level.all;

        logger.trace('start', Level.fatal).stop('stop');

        await later(() {
          expect(handler.records.first.level == Level.fatal, isTrue);
        });
      });

      test('throws when stopping tracer multiple times', () {
        final logger = Logger.detached()..level = Level.all;
        final t = logger.trace('start')..stop('stop');

        expect(() => t.stop('stop 2'),
            throwsA(const TypeMatcher<TracerStoppedError>()));
      });
    });

    test('allows custom level method extensions', () async {
      final handler = MemoryHandler();
      final logger = Logger.detached()
        ..handler = handler
        ..level = Level.all;

      logger.customLog('Log with custom handler!');

      await later(() {
        expect(handler.records.first.level == customLevel, isTrue);
      });
    });
  });
}
