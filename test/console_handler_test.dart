import 'dart:async' show runZoned, Zone, ZoneDelegate, ZoneSpecification;

import 'package:jetlog/formatters.dart';
import 'package:jetlog/handlers.dart' show ConsoleHandler;
import 'package:jetlog/jetlog.dart';
import 'package:jetlog/src/record_impl.dart';
import 'package:test/test.dart';

class _DebugOnlyFilter {
  bool call(Record record) => record.level == Level.debug;
}

void main() {
  group('ConsoleHandler', () {
    final records = <String>[];

    void newPrint(Zone self, ZoneDelegate parent, Zone zone, String message) =>
        records.add(message);

    final zoneSpec = ZoneSpecification(print: newPrint);
    final handler = ConsoleHandler(
        formatter: TextFormatter(
            (name, timestamp, level, message, fields) => message));

    setUp(records.clear);

    test('works correctly', () {
      runZoned<void>(() {
        handler.handle(RecordImpl(
            level: Level.debug,
            timestamp: DateTime.now(),
            message: 'ConsoleHandler test'));
      }, zoneSpecification: zoneSpec);

      expect(records, hasLength(1));
      expect(records[0], 'ConsoleHandler test');
    });

    test('filters record conditionally', () {
      handler.filter = _DebugOnlyFilter();
      runZoned<void>(() {
        handler.handle(RecordImpl(
            timestamp: DateTime.now(), level: Level.debug, message: 'Test'));
      }, zoneSpecification: zoneSpec);

      expect(records, hasLength(1));

      runZoned<void>(() {
        handler.handle(RecordImpl(
            timestamp: DateTime.now(), level: Level.info, message: 'Test 1'));
        handler.handle(RecordImpl(
            timestamp: DateTime.now(), level: Level.error, message: 'Test 1'));
        handler.handle(RecordImpl(
            timestamp: DateTime.now(), level: Level.warn, message: 'Test 1'));
        handler.handle(RecordImpl(
            timestamp: DateTime.now(), level: Level.debug, message: 'Test 2'));
      }, zoneSpecification: zoneSpec);

      expect(records, hasLength(2));
    });
  });
}
