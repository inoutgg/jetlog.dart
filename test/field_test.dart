import 'package:test/test.dart';
import 'package:jetlog/jetlog.dart';

void main() {
  group('Field', () {
    test('fields are equals when both have the same name', () {
      final f1 = Field<dynamic>(name: 'name', value: 123, kind: FieldKind.any);
      final f2 =
          Field<dynamic>(name: 'name', value: 'str', kind: FieldKind.any);
      final f3 =
          Field<dynamic>(name: 'name', value: 'str', kind: FieldKind.any);
      final f4 =
          Field<dynamic>(name: 'other-name', value: 'str', kind: FieldKind.any);

      // reflectivity
      expect(f1, equals(f1));
      expect(f2, equals(f2));

      // symmetry
      expect(f1, equals(f2));
      expect(f2, equals(f1));

      // transitivity
      expect(f1, equals(f3));
      expect(f2, equals(f3));

      expect(f1, isNot(equals(f4)));
    });

    group('Dur', () {
      test('Sets correct `FieldKind`', () {
        final field = Dur('Dur', Duration.zero);

        expect(field.kind, FieldKind.duration);
      });
    });

    group('Double', () {
      test('Sets correct `FieldKind`', () {
        final field = Double('Double', 0.2);

        expect(field.kind, FieldKind.double);
      });
    });

    group('Num', () {
      test('Sets correct `FieldKind`', () {
        final field = Num('Num', 10);

        expect(field.kind, FieldKind.number);
      });
    });

    group('Int', () {
      test('Sets correct `FieldKind`', () {
        final field = Int('Int', 12);

        expect(field.kind, FieldKind.integer);
      });
    });

    group('Str', () {
      test('Sets correct `FieldKind`', () {
        final field = Str('Str', 'str');

        expect(field.kind, FieldKind.string);
      });
    });

    group('Bool', () {
      test('Sets correct `FieldKind`', () {
        final field = Bool('Bool', false);

        expect(field.kind, FieldKind.boolean);
      });
    });

    group('DTM', () {
      test('Sets correct `FieldKind`', () {
        final field = DTM('DTM', DateTime.now());

        expect(field.kind, FieldKind.dateTime);
      });
    });

    group('Obj', () {
      test('Sets correct `FieldKind`', () {
        final field = Obj('Obj', null);

        expect(field.kind, FieldKind.object);
      });
    });
  });
}
