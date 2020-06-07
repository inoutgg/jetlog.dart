import 'package:jetlog/filters.dart' show MultiFilter;
import 'package:jetlog/jetlog.dart';
import 'package:jetlog/src/record_impl.dart';
import 'package:test/test.dart';

class _TestFilter1 {
  bool call(Record record) => record.name == 'Test';
}

class _TestFilter2 {
  bool call(Record record) => record.message == 'Test';
}

void main() {
  group('MultiFilter', () {
    test('allows any record when no filters set', () {
      final filter = MultiFilter([]);

      final record1 = RecordImpl(
          timestamp: DateTime.now(),
          name: 'abc',
          level: Level.info,
          message: 'abc',
          fields: const []);
      final record2 = RecordImpl(
          timestamp: DateTime.now(),
          name: 'cba',
          level: Level.info,
          message: 'baz',
          fields: const []);
      final record3 = RecordImpl(
          timestamp: DateTime.now(),
          name: 'foo',
          level: Level.info,
          message: 'bar',
          fields: const []);

      expect(filter.call(record1), isTrue);
      expect(filter.call(record2), isTrue);
      expect(filter.call(record3), isTrue);
    });

    test('delegates record to all filters', () {
      final filter1 = _TestFilter1();
      final filter2 = _TestFilter2();
      final filter = MultiFilter({filter1, filter2});

      final record1 = RecordImpl(
          timestamp: DateTime.now(),
          name: 'Test',
          level: Level.info,
          message: 'Test',
          fields: const []);
      final record2 = RecordImpl(
          timestamp: DateTime.now(),
          name: 'Test',
          level: Level.info,
          message: 'Test2',
          fields: const []);
      final record3 = RecordImpl(
          timestamp: DateTime.now(),
          name: 'Test2',
          level: Level.info,
          message: 'Test',
          fields: const []);

      expect(filter.call(record1), isTrue);
      expect(filter.call(record2), isFalse);
      expect(filter.call(record3), isFalse);
    });
  });
}
