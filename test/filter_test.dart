import 'package:test/test.dart';
import 'package:structlog/structlog.dart'
    show Filterer, Filter, FilterRegisterError, Level, Record;
import 'package:structlog/src/record_impl.dart';

class _TestFilterer extends Filterer {}

class _TestFilter1 extends Filter {
  @override
  bool filter(Record record) => record.name == 'Test';
}

class _TestFilter2 extends Filter {
  @override
  bool filter(Record record) => record.message == 'Test';
}

void main() {
  group('Filterer', () {
    group('Filterer#addFilter', () {
      test('throws error when register the same filter twice a time', () {
        final filter1 = _TestFilter1();
        final filterer = _TestFilterer();

        expect(() => filterer.addFilter(filter1), returnsNormally);
        expect(() => filterer.addFilter(filter1),
            throwsA(const TypeMatcher<FilterRegisterError>()));
      });
    });

    group('Filterer#filter', () {
      test('works correctly', () {
        final filterer = _TestFilterer()
          ..addFilter(_TestFilter1())
          ..addFilter(_TestFilter2());
        final record1 = RecordImpl(
            time: DateTime.now(),
            name: 'Test',
            level: Level.info,
            message: 'Test',
            fields: []);
        final record2 = RecordImpl(
            time: DateTime.now(),
            name: 'Test',
            level: Level.info,
            message: 'Test2',
            fields: []);
        final record3 = RecordImpl(
            time: DateTime.now(),
            name: 'Test2',
            level: Level.info,
            message: 'Test',
            fields: []);

        expect(filterer.filter(record1), isTrue);
        expect(filterer.filter(record2), isFalse);
        expect(filterer.filter(record3), isFalse);
      });
    });

    group('Filterer#removeFilter', () {
      test('works correctly', () {
        final filter1 = _TestFilter1();
        final filter2 = _TestFilter2();
        final filterer = _TestFilterer()
          ..addFilter(filter1)
          ..addFilter(filter2);
        final record1 = RecordImpl(
            time: DateTime.now(),
            name: 'Test',
            level: Level.info,
            message: 'Test',
            fields: []);
        final record2 = RecordImpl(
            time: DateTime.now(),
            name: 'Test2',
            level: Level.info,
            message: 'Test',
            fields: []);

        expect(filterer.filter(record1), isTrue);
        expect(filterer.filter(record2), isFalse);

        filterer.removeFilter(filter1);

        expect(filterer.filter(record2), isTrue);
      });

      test('ignores second and futher removes', () {
        final filter = _TestFilter1();
        final filterer = _TestFilterer()..addFilter(filter);

        expect(() => filterer.removeFilter(filter), returnsNormally);
        expect(() => filterer.removeFilter(filter), returnsNormally);
        expect(() => filterer.removeFilter(filter), returnsNormally);
      });

      test('ignores removes of unregistered filters', () {
        final filterer = _TestFilterer();
        final filter1 = _TestFilter1();
        final filter2 = _TestFilter1();

        expect(() => filterer.removeFilter(filter1), returnsNormally);
        expect(() => filterer.removeFilter(filter2), returnsNormally);
      });
    });
  });
}
