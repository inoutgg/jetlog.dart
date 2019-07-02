import 'dart:async' show StreamController;
import 'dart:convert' show utf8;

import 'package:test/test.dart';

import 'package:jetlog/jetlog.dart' show Level, Record;
import 'package:jetlog/formatters.dart' show TextFormatter;
import 'package:jetlog/handlers.dart' show StreamHandler;

import 'package:jetlog/src/record_impl.dart' show RecordImpl;

class _DebugOnlyFilter {
  bool call(Record record) => record.level == Level.debug;
}

void main() {
  group('StreamHandler', () {
    StreamController<List<int>> controller;

    setUp(() {
      controller = StreamController<List<int>>();
    });

    tearDown(() {
      controller.close();
    });

    group('constructor', () {
      test('throws on null stream', () {
        expect(() => StreamHandler(null), throwsArgumentError);
      });

      test('throws on null formatter', () {
        expect(() => StreamHandler(controller, formatter: null),
            throwsArgumentError);
      });
    });

    group('#handler', () {
      test('delegates records to downstream', () async {
        final handler = StreamHandler(controller,
            formatter: TextFormatter((
                    {message, level, timestamp, name, fields}) =>
                '$level: $message'));

        handler.handle(RecordImpl(
            timestamp: DateTime.now(),
            level: Level.fatal,
            message: 'Fatal message'));
        handler.handle(RecordImpl(
            timestamp: DateTime.now(),
            level: Level.info,
            message: 'Info message'));

        await expectLater(
            controller.stream,
            emitsInOrder(<List<int>>[
              utf8.encode('${Level.fatal.name}: Fatal message\r\n'),
              utf8.encode('${Level.info.name}: Info message\r\n'),
            ]));
      });

      test('filters record conditionally', () async {
        final handler = StreamHandler(controller,
            formatter: TextFormatter((
                    {message, level, timestamp, name, fields}) =>
                '$level: $message'));

        handler.filter = _DebugOnlyFilter();

        handler.handle(RecordImpl(
            timestamp: DateTime.now(), level: Level.debug, message: 'Test'));

        handler.handle(RecordImpl(
            timestamp: DateTime.now(), level: Level.info, message: 'Test 1'));
        handler.handle(RecordImpl(
            timestamp: DateTime.now(), level: Level.danger, message: 'Test 2'));

        controller.close();

        await expectLater(
            controller.stream,
            emitsInOrder(<Matcher>[
              neverEmits([
                utf8.encode('${Level.info.name}: Test 1\r\n'),
                utf8.encode('${Level.danger.name}: Test 2\r\n')
              ]),
              emits(utf8.encode('${Level.debug.name}: Test\r\n')),
              emitsDone,
            ]));
      });
    });
  });
}
