import 'package:test/test.dart';
import 'package:structlog/structlog.dart'
    show Filterer, Filter, FilterRegisterError, Level, Record;
import 'package:structlog/src/internals/record.dart';

class TestFilterer extends Filterer {}

class Test1Filter extends Filter {
  @override
  bool filter(Record record) => record.name == 'Test';
}

class Test2Filter extends Filter {
  @override
  bool filter(Record record) => record.message == 'Test';
}

void main() {
  group('Filterer', () {
    group('Filterer#addFilter', () {
      test('throws error when register the same filter twice a time', () {
        final filter1 = Test1Filter();
        final filterer = TestFilterer();

        expect(() => filterer.addFilter(filter1), returnsNormally);
        expect(() => filterer.addFilter(filter1),
            throwsA(const TypeMatcher<FilterRegisterError>()));
      });
    });

    group('Filterer#filter', () {
      test('works correctly', () {
        final filterer = TestFilterer()
          ..addFilter(Test1Filter())
          ..addFilter(Test2Filter());
        final record1 = RecordImpl(
            name: 'Test', level: Level.info, message: 'Test', fields: []);
        final record2 = RecordImpl(
            name: 'Test', level: Level.info, message: 'Test2', fields: []);
        final record3 = RecordImpl(
            name: 'Test2', level: Level.info, message: 'Test', fields: []);

        expect(filterer.filter(record1), isTrue);
        expect(filterer.filter(record2), isFalse);
        expect(filterer.filter(record3), isFalse);
      });
    });

    group('Filterer#removeFilter', () {
      test('works correctly', () {
        final filter1 = Test1Filter();
        final filter2 = Test2Filter();
        final filterer = TestFilterer()
          ..addFilter(filter1)
          ..addFilter(filter2);
        final record1 = RecordImpl(
            name: 'Test', level: Level.info, message: 'Test', fields: []);
        final record2 = RecordImpl(
            name: 'Test2', level: Level.info, message: 'Test', fields: []);

        expect(filterer.filter(record1), isTrue);
        expect(filterer.filter(record2), isFalse);

        filterer.removeFilter(filter1);

        expect(filterer.filter(record2), isTrue);
      });
    });
  });
}
