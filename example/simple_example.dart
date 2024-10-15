import 'dart:io';

import 'package:jetlog/formatters.dart';
import 'package:jetlog/handlers.dart';
import 'package:jetlog/jetlog.dart';

final _defaultFormatter = TextFormatter.withDefaults();

void main() {
  final logger = Logger.detached()
    ..handler = ConsoleHandler(formatter: _defaultFormatter);

  logger
      .info('A new log with bound PID appears on a screen', [Int('pid', pid)]);
}
