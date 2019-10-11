import 'package:jetlog/jetlog.dart';
import 'package:test/test.dart';

void main() {
  group('Field', () {
    test('fields are equals when both have the same name', () {
      const f1 = Field<dynamic>(name: 'name', value: 123, kind: FieldKind.any);
      const f2 =
          Field<dynamic>(name: 'name', value: 'str', kind: FieldKind.any);
      const f3 =
          Field<dynamic>(name: 'name', value: 'str', kind: FieldKind.any);
      const f4 =
          Field<dynamic>(name: 'other-name', value: 'str', kind: FieldKind.any);

      // reflectivity
      expect(f1, equals(f1));
      expect(f2, equals(f2));

      // symmetry
      expect(f1, equals(f2));
      expect(f2, equals(f1));
      expect(f1 == f1, isTrue);
      expect(f1 == f2, isTrue);

      // transitivity
      expect(f1, equals(f3));
      expect(f2, equals(f3));

      expect(f1, isNot(equals(f4)));
    });

    group('Dur', () {
      test('Sets correct `FieldKind`', () {
        const field = Dur('Dur', Duration.zero);
        final lazyField = Dur.lazy('LazyDur', () => Duration.zero);

        expect(field.kind, FieldKind.duration);
        expect(lazyField.kind, FieldKind.duration);
      });
    });

    group('Double', () {
      test('Sets correct `FieldKind`', () {
        const field = Double('Double', 0.2);
        final lazyField = Double.lazy('LazyDouble', () => 2);

        expect(field.kind, FieldKind.double);
        expect(lazyField.kind, FieldKind.double);
      });
    });

    group('Num', () {
      test('Sets correct `FieldKind`', () {
        const field = Num('Num', 10);
        final lazyField = Num.lazy('LazyNum', () => 10);

        expect(field.kind, FieldKind.number);
        expect(lazyField.kind, FieldKind.number);
      });
    });

    group('Int', () {
      test('Sets correct `FieldKind`', () {
        const field = Int('Int', 12);
        final lazyField = Int.lazy('LazyInt', () => 12);

        expect(field.kind, FieldKind.integer);
        expect(lazyField.kind, FieldKind.integer);
      });
    });

    group('Str', () {
      test('Sets correct `FieldKind`', () {
        const field = Str('Str', 'str');
        final lazyField = Str.lazy('LazyStr', () => '');

        expect(field.kind, FieldKind.string);
        expect(lazyField.kind, FieldKind.string);
      });
    });

    group('Bool', () {
      test('Sets correct `FieldKind`', () {
        const field = Bool('Bool', false);
        final lazyField = Bool.lazy('LazyBool', () => false);

        expect(field.kind, FieldKind.boolean);
        expect(lazyField.kind, FieldKind.boolean);
      });
    });

    group('DTM', () {
      test('Sets correct `FieldKind`', () {
        final field = DTM('DTM', DateTime.now());
        final lazyField = DTM.lazy('LazyDTM', () => DateTime.now());

        expect(field.kind, FieldKind.dateTime);
        expect(lazyField.kind, FieldKind.dateTime);
      });
    });

    group('Obj', () {
      test('Sets correct `FieldKind`', () {
        final field = Obj('Obj', null);
        final lazyField = Obj.lazy('LazyObj', () => null);

        expect(field.kind, FieldKind.object);
        expect(lazyField.kind, FieldKind.object);
      });
    });
  });
}
