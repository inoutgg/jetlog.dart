import 'package:strlog/formatters.dart' show FormatterBase;
import 'package:strlog/strlog.dart' show Field, FieldKind;
import 'package:test/test.dart';

void main() {
  group('FormatterBase', () {
    group('#getFieldFormatter', () {
      test('it returns normally', () {
        final f = CustomFormatter();

        expect(() => f.setFieldFormatter(FieldKind.number, (field) => '$field'),
            returnsNormally);

        // Twice
        expect(
            () => f.setFieldFormatter(FieldKind.boolean, (field) => '$field'),
            returnsNormally);
        expect(
            () => f.setFieldFormatter(FieldKind.boolean, (field) => '$field'),
            returnsNormally);
      });
    });

    group('#setFieldFormatter', () {
      test('it works', () {
        final f = CustomFormatter();
        String handler(Field field) => '$field';

        expect(() => f.setFieldFormatter(FieldKind.double, handler),
            returnsNormally);
        expect(f.getFieldFormatter(FieldKind.double), handler);
      });

      test('it throws if no formatters registered for given field kind', () {
        final f = CustomFormatter();

        expect(() => f.getFieldFormatter(FieldKind.double),
            throwsA(const TypeMatcher<StateError>()));
      });
    });
  });
}

final class CustomFormatter with FormatterBase<String> {}
