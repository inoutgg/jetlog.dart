import 'dart:convert' show utf8, json, JsonEncoder;

import 'package:test/test.dart';
import 'package:structlog/structlog.dart'
    show Dur, DTM, Str, Record, Obj, Field, Level, Loggable;
import 'package:structlog/formatters.dart' show JsonFormatter;

import 'package:structlog/src/record_impl.dart';

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
      final formatter = JsonFormatter();
      final result = formatter.call(record);

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

      expect(dict, equals(json.decode(utf8.decode(result))));
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
          result, utf8.encode(JsonEncoder.withIndent(' ' * 4).convert(dict)));
    });
  });
}
