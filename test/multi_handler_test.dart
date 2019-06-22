import 'package:test/test.dart';

import 'package:structlog/structlog.dart' show Filter, Level, Record;
import 'package:structlog/handlers.dart' show MultiHandler, MemoryHandler;

import 'package:structlog/src/record_impl.dart' show RecordImpl;

class _DebugOnlyFilter extends Filter {
  @override
  bool filter(Record record) => record.level == Level.debug;
}

void main() {
  group('MultiHandler', () {
    group('constructor', () {
      test('throws on empty filters list', () {
        expect(() => MultiHandler([]), throwsArgumentError);
      });

      test('throws on null', () {
        expect(() => MultiHandler(null), throwsArgumentError);
      });
    });

    group('#handler', () {
      test('delegates records to all handlers', () {
        final h0 = MemoryHandler();
        MultiHandler handler = MultiHandler([h0]);

        handler.handle(RecordImpl(
            timestamp: DateTime.now(), level: Level.fatal, message: 'Test message'));
        handler.handle(RecordImpl(
            timestamp: DateTime.now(), level: Level.fatal, message: 'Test message'));

        expect(h0.records, hasLength(2));
        expect(h0.records.last.level, equals(Level.fatal));

        final h1 = MemoryHandler();
        final h2 = MemoryHandler();
        handler = MultiHandler([h1, h2]);

        handler.handle(RecordImpl(
            timestamp: DateTime.now(), level: Level.debug, message: 'Test'));

        expect(h1.records, hasLength(1));
        expect(h2.records, hasLength(1));

        handler.handle(RecordImpl(
            timestamp: DateTime.now(), level: Level.debug, message: 'Test2'));

        expect(h1.records, hasLength(2));
        expect(h2.records, hasLength(2));
        expect(h1.records, orderedEquals(h2.records));
      });

      test('filters record conditionally', () {
        final h1 = MemoryHandler();
        final h2 = MemoryHandler();
        final h3 = MemoryHandler();
        final handler = MultiHandler([h1, h2, h3]);

        handler.filter = _DebugOnlyFilter();

        handler.handle(RecordImpl(
            timestamp: DateTime.now(), level: Level.debug, message: 'Test'));

        expect(h1.records, hasLength(1));
        expect(h2.records, hasLength(1));
        expect(h3.records, hasLength(1));

        handler.handle(RecordImpl(
            timestamp: DateTime.now(), level: Level.info, message: 'Test 1'));

        expect(h1.records, hasLength(1));
        expect(h2.records, hasLength(1));
        expect(h3.records, hasLength(1));
      });
    });
  });
}
