import 'package:structlog/src/field.dart';
import 'package:test/test.dart';
import 'package:structlog/src/field.dart' show Field, FieldKind, Loggable;
import 'package:structlog/src/internals/fieldset.dart';

class LoggableObject implements Loggable {
  LoggableObject(this.field1, this.field2);

  final int field1;
  final String field2;

  @override
  void toFieldSet(FieldSetCollector collector) => collector
    ..addInt('field1', field1)
    ..addString('field2', field2);
}

void main() {
  group('FieldSetBuilder', () {
    test('#add correctly appends a field to field set', () {
      final builder = FieldSetBuilder()
        ..add(const Field<int>(
            name: 'custom-field1', value: 0x1, kind: FieldKind.integer));
      final fields = builder.build();

      expect(fields.length, 1);
      expect(fields.first.name, 'custom-field1');

      builder.add(const Field<int>(
          name: 'custom-field2', value: 0x2, kind: FieldKind.integer));

      expect(fields.first.name, 'custom-field1');
      expect(fields.last.name, 'custom-field2');
    });

    test('Sets fields\' kinds correctly', () {
      final builder = FieldSetBuilder()
        ..addBool('boolean', false)
        ..addString('string', 'str')
        ..addDouble('float', 1.23)
        ..addInt('integer', 1)
        ..addNum('number', 3.45)
        ..addDuration('duration', Duration(seconds: 1))
        ..addDateTime('dateTime', DateTime.now());
      final fields = builder.build().toList();

      expect(fields[0].kind, equals(FieldKind.boolean));
      expect(fields[1].kind, equals(FieldKind.string));
      expect(fields[2].kind, equals(FieldKind.float));
      expect(fields[3].kind, equals(FieldKind.integer));
      expect(fields[4].kind, equals(FieldKind.number));
      expect(fields[5].kind, equals(FieldKind.duration));
      expect(fields[6].kind, equals(FieldKind.dateTime));
    });
  });

  test('Supports loggable classes', () {
    final builder = FieldSetBuilder()
      ..addString('string', 'str')
      ..addObject('loggable', LoggableObject(1, 'loggable-string'));

    final fields = builder.build().toList();

    expect(fields.length, same(2));

    final objectFields = (fields[1].value as FieldSet).toList();

    expect(fields[0].value, equals('str'));
    expect(objectFields[0].value, same(1));
    expect(objectFields[1].value, same('loggable-string'));
  });
}
