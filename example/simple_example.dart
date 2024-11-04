/// This example shows how to simply log to the console.
library;

import 'dart:io' show pid;

import 'package:strlog/formatters.dart';
import 'package:strlog/handlers.dart';
import 'package:strlog/strlog.dart';

final _defaultFormatter = TextFormatter.withDefaults();

void main() {
  final logger = Logger.detached()
    ..handler = ConsoleHandler(formatter: _defaultFormatter.call);

  logger
      .info('A new log with bound PID appears on a screen', [Int('pid', pid)]);
}
