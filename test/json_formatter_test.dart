import 'dart:convert' show utf8, json, JsonEncoder;

import 'package:jetlog/formatters.dart' show JsonFormatter;
import 'package:jetlog/jetlog.dart'
    show DTM, Dur, Field, FieldKind, Level, Loggable, Obj, Record, Str;
import 'package:jetlog/src/record_impl.dart';
import 'package:test/test.dart';

class Klass extends Loggable {
  Klass(this.dur, this.name, [this.klass]);

  final String name;
  final Duration dur;
  final Klass klass;

  @override
  Iterable<Field> toFields() {
    final result = <Field>{};

    result
      ..add(Str('name', name))
      ..add(Dur('dur', dur))
      ..add(Obj('klass', klass));

    return result;
  }
}

void main() {
  group('JsonFormatter', () {
    DateTime timestamp;
    String message;
    Level level;
    Record record;

    setUp(() {
      timestamp = DateTime.now();
      level = Level.info;
      message = 'Test';
      record = RecordImpl(
          name: null,
          timestamp: timestamp,
          level: level,
          message: message,
          fields: [const Dur('dur', Duration.zero), DTM('dtm', timestamp)]);
    });

    test('formats correctly with defaults', () {
      final formatter1 = JsonFormatter();
      final formatter2 = JsonFormatter.defaultFormatter;
      final result1 = formatter1.call(record);
      final result2 = formatter2.call(record);

      final dict = {
        'name': null,
        'level': {
          'severity': level.value,
          'name': level.name,
        },
        'message': message,
        'timestamp': timestamp.toString(),
        'dur': Duration.zero.toString(),
        'dtm': timestamp.toString(),
      };

      expect(dict, equals(json.decode(utf8.decode(result1))));
      expect(dict, equals(json.decode(utf8.decode(result2))));
    });

    test('uses custom level formatter', () {
      final formatter = JsonFormatter(formatLevel: (level) => level.name);
      final result = formatter(record);

      final dict = {
        'name': null,
        'level': level.name,
        'message': message,
        'timestamp': timestamp.toString(),
        'dur': Duration.zero.toString(),
        'dtm': timestamp.toString(),
      };

      expect(dict, equals(json.decode(utf8.decode(result))));
    });

    test('uses custom fields encoders', () {
      final formatter = JsonFormatter()
        ..setFieldFormatter(
            FieldKind.dateTime, (_) => const MapEntry('foo', 'bar'));
      final record = RecordImpl(
          name: null,
          timestamp: timestamp,
          level: level,
          message: message,
          fields: [DTM('dateTime', DateTime.now())]);
      final result = formatter(record);

      final dict = {
        'name': null,
        'level': {
          'severity': level.value,
          'name': level.name,
        },
        'message': message,
        'timestamp': timestamp.toString(),
        'foo': 'bar'
      };

      expect(dict, equals(json.decode(utf8.decode(result))));
    });

    test('does not throw on null fields', () {
      final formatter = JsonFormatter();
      final record = RecordImpl(
          name: null,
          timestamp: timestamp,
          level: level,
          message: message,
          fields: null);
      final result = formatter(record);

      final dict = {
        'name': null,
        'level': {
          'severity': level.value,
          'name': level.name,
        },
        'message': message,
        'timestamp': timestamp.toString(),
      };

      expect(dict, equals(json.decode(utf8.decode(result))));
    });

    test('uses custom timestamps formatter', () {
      final newTimestamp = DateTime.now();
      final formatter = JsonFormatter(
          formatTimestamp: (timestamp) => newTimestamp.toString());
      final result = formatter(record);

      final dict = {
        'name': null,
        'level': {
          'severity': level.value,
          'name': level.name,
        },
        'message': message,
        'timestamp': newTimestamp.toString(),
        'dur': Duration.zero.toString(),
        'dtm': timestamp.toString(),
      };

      expect(dict, equals(json.decode(utf8.decode(result))));
    });

    test('support indentation', () {
      final formatter = JsonFormatter.withIndent(4);
      final result = formatter(record);

      final dict = {
        'level': {
          'name': level.name,
          'severity': level.value,
        },
        'message': message,
        'name': null,
        'timestamp': timestamp.toString(),
        'dur': Duration.zero.toString(),
        'dtm': timestamp.toString(),
      };

      expect(
          utf8.decode(result), JsonEncoder.withIndent(' ' * 4).convert(dict));
    });

    test('supports nested fields', () {
      final formatter = JsonFormatter();
      record = RecordImpl(
          name: null,
          timestamp: timestamp,
          level: level,
          message: message,
          fields: [
            const Dur('dur', Duration.zero),
            DTM('dtm', timestamp),
            Obj(
                'klass',
                Klass(
                    Duration.zero, 'test', Klass(Duration.zero, 'nested-test')))
          ]);
      final result = formatter(record);

      final dict = {
        'level': {
          'name': level.name,
          'severity': level.value,
        },
        'message': message,
        'name': null,
        'timestamp': timestamp.toString(),
        'dur': Duration.zero.toString(),
        'dtm': timestamp.toString(),
        'klass': {
          'name': 'test',
          'dur': Duration.zero.toString(),
          'klass': {
            'name': 'nested-test',
            'dur': Duration.zero.toString(),
            'klass': null,
          }
        }
      };

      expect(utf8.decode(result), json.encode(dict));
    });

    test('defines formatters for all builtin field kinds', () {
      final formatter1 = JsonFormatter();

      expect(() => formatter1.getFieldFormatter(FieldKind.boolean),
          returnsNormally);
      expect(() => formatter1.getFieldFormatter(FieldKind.dateTime),
          returnsNormally);
      expect(() => formatter1.getFieldFormatter(FieldKind.double),
          returnsNormally);
      expect(() => formatter1.getFieldFormatter(FieldKind.duration),
          returnsNormally);
      expect(() => formatter1.getFieldFormatter(FieldKind.integer),
          returnsNormally);
      expect(() => formatter1.getFieldFormatter(FieldKind.number),
          returnsNormally);
      expect(() => formatter1.getFieldFormatter(FieldKind.object),
          returnsNormally);
      expect(() => formatter1.getFieldFormatter(FieldKind.string),
          returnsNormally);

      final formatter2 = JsonFormatter.withIndent(4);

      expect(() => formatter2.getFieldFormatter(FieldKind.boolean),
          returnsNormally);
      expect(() => formatter2.getFieldFormatter(FieldKind.dateTime),
          returnsNormally);
      expect(() => formatter2.getFieldFormatter(FieldKind.double),
          returnsNormally);
      expect(() => formatter2.getFieldFormatter(FieldKind.duration),
          returnsNormally);
      expect(() => formatter2.getFieldFormatter(FieldKind.integer),
          returnsNormally);
      expect(() => formatter2.getFieldFormatter(FieldKind.number),
          returnsNormally);
      expect(() => formatter2.getFieldFormatter(FieldKind.object),
          returnsNormally);
      expect(() => formatter2.getFieldFormatter(FieldKind.string),
          returnsNormally);
    });
  });
}
