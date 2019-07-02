import 'dart:convert' show utf8, json, JsonEncoder;

import 'package:test/test.dart';
import 'package:jetlog/jetlog.dart'
    show Dur, DTM, Str, Record, Obj, Field, Level, Loggable;
import 'package:jetlog/formatters.dart' show JsonFormatter;

import 'package:jetlog/src/record_impl.dart';

class Klass extends Loggable {
  Klass(this.dur, this.name);

  final String name;
  final Duration dur;

  @override
  Iterable<Field> toFields() {
    final result = <Field>{};

    result..add(Str('name', name))..add(Dur('dur', dur));

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

    test('uses custom fields formatter', () {
      final formatter = JsonFormatter(
          formatFields: (fields) => <String, dynamic>{'foo': 'bar'});
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
      final formatter = JsonFormatter(formatFields: (fields) => null);
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
      final formatter = JsonFormatter(indent: 4);
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
            Obj('klass', Klass(Duration.zero, 'test'))
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
        }
      };

      expect(utf8.decode(result), json.encode(dict));
    });
  });
}
