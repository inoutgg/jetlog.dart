import 'dart:convert' show utf8, json, JsonEncoder;

import 'package:jetlog/formatters.dart' show JsonFormatter;
import 'package:jetlog/jetlog.dart'
    show
        Bool,
        DTM,
        Double,
        Dur,
        Field,
        FieldKind,
        Int,
        Level,
        Loggable,
        Num,
        Obj,
        Str;
import 'package:jetlog/src/record_impl.dart';
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
      ..add(Obj('klass', klass));

    return result;
  }
}

void main() {
  group('JsonFormatter', () {
    final timestamp = DateTime.now();
    final level = Level.info;
    final message = 'Test';
    final record = RecordImpl(
        name: null,
        timestamp: timestamp,
        level: level,
        message: message,
        fields: [const Dur('dur', Duration.zero), DTM('dtm', timestamp)]);

    test('formats correctly with defaults', () {
      final formatter1 = JsonFormatter();
      final formatter2 = JsonFormatter.withDefaults();
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
      final record = RecordImpl(
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

    test('should override duplicated fields', () {
      final formatter = JsonFormatter.withDefaults();
      final record1 = RecordImpl(
          name: 'json-formatter-test',
          timestamp: timestamp,
          level: level,
          message: message,
          fields: [
            const Dur('dur', Duration.zero),
            DTM('dtm', timestamp),
            const Str('name', 'test-name'),
          ]);
      final record2 = RecordImpl(
          name: '',
          timestamp: timestamp,
          level: level,
          message: message,
          fields: const [
            Dur('dur', Duration.zero),
            Int('int', 10),
            Int('int', 20),
            Str('name', 'test-name'),
          ]);
      final result1 = formatter(record1);
      final result2 = formatter(record2);

      final dict1 = {
        'level': {
          'name': level.name,
          'severity': level.value,
        },
        'message': message,
        'name': 'test-name',
        'timestamp': timestamp.toString(),
        'dur': Duration.zero.toString(),
        'dtm': timestamp.toString(),
      };
      final dict2 = {
        'level': {
          'name': level.name,
          'severity': level.value,
        },
        'message': message,
        'name': 'test-name',
        'timestamp': timestamp.toString(),
        'dur': Duration.zero.toString(),
        'int': 20,
      };
      expect(utf8.decode(result1), json.encode(dict1));
      expect(utf8.decode(result2), json.encode(dict2));
    });

    test('should translate Date types to equivalent JSON types by default', () {
      final formatter = JsonFormatter.withDefaults();
      final record = RecordImpl(
          name: 'Hello World',
          timestamp: DateTime.now(),
          level: level,
          message: message,
          fields: [
            const Bool('bool', true),
            DTM('dtm', DateTime.now()),
            const Double('double', 0.0),
            const Dur('dur', Duration.zero),
            const Int('int', 20),
            const Num('num', 30.1),
            const Str('str', 'test-name'),
          ]);
      final result = formatter(record);
      final dict = json.decode(utf8.decode(result)) as Map<String, dynamic>;

      expect(dict['bool'], isA<bool>());
      expect(dict['dtm'], isA<String>());
      expect(dict['double'], isA<double>());
      expect(dict['dur'], isA<String>());
      expect(dict['int'], isA<int>());
      expect(dict['num'], isA<num>());
      expect(dict['str'], isA<String>());
    });
  });
}
