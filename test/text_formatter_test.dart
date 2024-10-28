import 'dart:convert' show utf8;

import 'package:strlog/formatters.dart' show TextFormatter;
import 'package:strlog/strlog.dart'
    show DTM, Dur, Field, FieldKind, Level, Loggable, Obj, Str, Int, Group;
import 'package:strlog/src/record_impl.dart';
import 'package:test/test.dart';

class Klass extends Loggable {
  Klass(this.dur, this.name, [this.klass]);

  final String name;
  final Duration dur;
  final Klass? klass;

  @override
  Iterable<Field> toFields() {
    final result = <Field>{};

    result
      ..add(Str('name', name))
      ..add(Dur('dur', dur))
      ..add(Obj('subclass', klass));

    return result;
  }
}

void main() {
  group('TextFormatter', () {
    test('formats correctly with defaults', () {
      final encoder1 = TextFormatter(
          (name, timestamp, level, message, fields) =>
              '$name $level $timestamp $message $fields'.trim());
      final encoder2 =
          TextFormatter((name, timestamp, level, message, fields) => '');

      final timestamp = DateTime.now();
      const level = Level.info;
      const message = 'Test';
      final record = RecordImpl(
          name: null,
          timestamp: timestamp,
          level: level,
          message: message,
          fields: [const Dur('dur', Duration.zero), DTM('dtm', timestamp)]);
      final result1 = encoder1.call(record);
      final result2 = encoder2.call(record);

      expect(
          utf8.decode(result1),
          '${level.name} ${timestamp.toString()} $message '
          'dur=${Duration.zero} dtm=$timestamp\r\n');
      expect(result2, <int>[]);
    });

    test('TextFormatter.defaultFormatter formats correctly', () {
      final f = TextFormatter.withDefaults();

      final timestamp = DateTime.now();
      const level = Level.info;
      const message = 'Test';
      final record1 = RecordImpl(
          name: "str",
          timestamp: timestamp,
          level: level,
          message: message,
          fields: [const Dur('dur', Duration.zero), DTM('dtm', timestamp)]);
      final record2 = RecordImpl(
          name: null,
          timestamp: timestamp,
          level: level,
          message: message,
          fields: [const Dur('dur', Duration.zero), DTM('dtm', timestamp)]);
      final result1 = f.call(record1);
      final result2 = f.call(record2);

      expect(utf8.decode(result1),
          'str $timestamp [${level.name}]: $message dur=${Duration.zero} dtm=$timestamp\r\n');
      expect(utf8.decode(result2),
          '$timestamp [${level.name}]: $message dur=${Duration.zero} dtm=$timestamp\r\n');
    });

    test('supports nested fields with defaults', () {
      final encoder = TextFormatter((name, timestamp, level, message, fields) =>
          '$name $level $timestamp $message $fields'.trim());

      final timestamp = DateTime.now();
      const level = Level.info;
      const message = 'Test';
      final klass =
          Klass(Duration.zero, '__name__', Klass(Duration.zero, '__name__'));
      final record = RecordImpl(
          name: null,
          timestamp: timestamp,
          level: level,
          message: message,
          fields: [
            const Dur('dur', Duration.zero),
            DTM('dtm', timestamp),
            Obj('klass', klass),
            Group('group', [
              const Str('key', 'value'),
              Obj('klass', klass),
              const Group('subgroup', [Int('int', 10)])
            ])
          ]);

      final result = encoder.call(record);

      expect(
          utf8.decode(result),
          '${level.name} ${timestamp.toString()} $message '
          'dur=0:00:00.000000 dtm=$timestamp '
          'klass.name=__name__ klass.dur=0:00:00.000000 '
          'klass.subclass.name=__name__ klass.subclass.dur=0:00:00.000000 klass.subclass.subclass=null '
          'group.key=value '
          'group.klass.name=__name__ group.klass.dur=0:00:00.000000 '
          'group.klass.subclass.name=__name__ '
          'group.klass.subclass.dur=0:00:00.000000 group.klass.subclass.subclass=null '
          'group.subgroup.int=10'
          '\r\n');
    });

    test('uses custom level encoder', () {
      final encoder = TextFormatter(
          (name, timestamp, level, message, fields) => '$level',
          formatLevel: (level) => '$level');

      const level = Level.info;
      final record = RecordImpl(
          name: null, timestamp: DateTime.now(), level: level, message: '');

      final result = encoder.call(record);

      expect(utf8.decode(result), '$level\r\n');
    });

    test('uses custom time encoder', () {
      final encoder = TextFormatter(
          (name, timestamp, level, message, fields) => '$timestamp',
          formatTimestamp: (timestamp) =>
              timestamp.millisecondsSinceEpoch.toString());

      final timestamp = DateTime.now();
      final record = RecordImpl(
          name: null, timestamp: timestamp, level: Level.info, message: '');

      final result = encoder.call(record);

      expect(utf8.decode(result), '${timestamp.millisecondsSinceEpoch}\r\n');
    });

    test('uses custom field encoder', () {
      final encoder =
          TextFormatter((name, timestamp, level, message, fields) => '$fields')
            ..setFieldFormatter(FieldKind.duration, (field) => 'custom-field');

      final timestamp = DateTime.now();
      final record = RecordImpl(
          name: null,
          timestamp: timestamp,
          level: Level.info,
          message: '',
          fields: const [Dur('dur', Duration.zero)]);

      final result = encoder.call(record);

      expect(utf8.decode(result), 'custom-field\r\n');
    });

    test('defines formatters for all builtin field kinds', () {
      final formatter = TextFormatter.withDefaults();

      expect(() => formatter.getFieldFormatter(FieldKind.boolean),
          returnsNormally);
      expect(() => formatter.getFieldFormatter(FieldKind.dateTime),
          returnsNormally);
      expect(
          () => formatter.getFieldFormatter(FieldKind.double), returnsNormally);
      expect(() => formatter.getFieldFormatter(FieldKind.duration),
          returnsNormally);
      expect(() => formatter.getFieldFormatter(FieldKind.integer),
          returnsNormally);
      expect(
          () => formatter.getFieldFormatter(FieldKind.number), returnsNormally);
      expect(
          () => formatter.getFieldFormatter(FieldKind.object), returnsNormally);
      expect(
          () => formatter.getFieldFormatter(FieldKind.string), returnsNormally);
      expect(
          () => formatter.getFieldFormatter(FieldKind.group), returnsNormally);
    });
  });
}
