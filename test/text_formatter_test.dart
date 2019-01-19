import 'package:test/test.dart';
import 'package:structlog/structlog.dart'
    show Dur, DTM, Str, Obj, Field, Level, Loggable;

import 'package:structlog/formatters.dart' show Formatter, TextFormatter;
import 'package:structlog/src/internals/record.dart';

class Klass extends Loggable {
  Klass(this.dur, this.name);

  final String name;
  final Duration dur;

  @override
  Iterable<Field> toFields() {
    final result = Set<Field>();

    result..add(Str('name', name))..add(Dur('dur', dur));

    return result;
  }
}

void main() {
  group('TextFormatter', () {
    test('implements Formatter', () {
      expect(TextFormatter is Formatter<String>, isTrue);
    }, skip: true);

    test('formats correctly with defaults', () {
      final formatter1 = TextFormatter(
          format: ({name, level, time, message, fields}) =>
              '$name $level $time $message $fields');
      final formatter2 =
          TextFormatter(format: ({name, level, time, message, fields}) => '');

      final time = DateTime.now();
      const level = Level.info;
      const message = 'Test';
      final record = RecordImpl(
          name: null,
          time: time,
          level: level,
          message: message,
          fields: [const Dur('dur', Duration.zero), DTM('dtm', time)]);
      final result1 = formatter1.format(record);
      final result2 = formatter2.format(record);

      expect(
          result1,
          '${level.name} ${time.toIso8601String()} $message '
          'dur=0:00:00.000000 dtm=$time');
      expect(result2, '');
    });

    test('supports nested fields with defaults', () {
      final formatter = TextFormatter(
          format: ({name, level, time, message, fields}) =>
              '$name $level $time $message $fields');

      final time = DateTime.now();
      const level = Level.info;
      const message = 'Test';
      final klass = Klass(Duration.zero, '__name__');
      final record = RecordImpl(
          name: null,
          time: time,
          level: level,
          message: message,
          fields: [
            const Dur('dur', Duration.zero),
            DTM('dtm', time),
            Obj('klass', klass)
          ]);

      final result = formatter.format(record);

      expect(
          result,
          '${level.name} ${time.toIso8601String()} $message '
          'dur=0:00:00.000000 dtm=$time '
          'klass.name=__name__ klass.dur=0:00:00.000000');
    });

    test('uses custom level formatter', () {
      final formatter = TextFormatter(
          format: ({name, time, message, level, fields}) => '$level',
          formatLevel: (level) => '$level');

      const level = Level.info;
      final record = RecordImpl(
          name: null, time: DateTime.now(), level: level, message: '');

      final result = formatter.format(record);

      expect(result, level.toString());
    });

    test('uses custom time formatter', () {
      final formatter = TextFormatter(
          format: ({name, time, message, level, fields}) => '$time',
          formatTime: (time) => time.millisecondsSinceEpoch.toString());

      final time = DateTime.now();
      final record =
          RecordImpl(name: null, time: time, level: Level.info, message: '');

      final result = formatter.format(record);

      expect(result, time.millisecondsSinceEpoch.toString());
    });

    test('uses custom logger name formatter', () {
      final formatter = TextFormatter(
          format: ({name, time, message, level, fields}) => '$name',
          formatName: (name) => '__${name}__');

      final record = RecordImpl(
          name: 'custom_name',
          time: DateTime.now(),
          level: Level.info,
          message: '');

      final result = formatter.format(record);

      expect(result, '__custom_name__');
    });

    test('uses custom time formatter', () {
      final formatter = TextFormatter(
          format: ({name, time, message, level, fields}) => '$time',
          formatTime: (time) => time.millisecondsSinceEpoch.toString());

      final time = DateTime.now();
      final record =
          RecordImpl(name: null, time: time, level: Level.info, message: '');

      final result = formatter.format(record);

      expect(result, time.millisecondsSinceEpoch.toString());
    });

    test('uses custom field formatter', () {
      final formatter = TextFormatter(
          format: ({name, time, message, level, fields}) => '$fields',
          formatField: (field) => 'field:${field.name}');

      final time = DateTime.now();
      final record = RecordImpl(
          name: null,
          time: time,
          level: Level.info,
          message: '',
          fields: [const Dur('dur', Duration.zero)]);

      final result = formatter.format(record);

      expect(result, 'field:dur');
    });
  });
}
