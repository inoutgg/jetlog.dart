/// This example demonstrates how to filter log records and direct them to stdout
/// or stderr based on severity level.
library;

import 'dart:io' show stderr, stdout;
import 'package:strlog/formatters.dart';
import 'package:strlog/handlers.dart';
import 'package:strlog/strlog.dart';

final _logger = Logger.detached();
final _defaultFormatter = TextFormatter.withDefaults();
final stderrLevels = {Level.warn, Level.error, Level.fatal};

bool _stderrFilter(Record record) => stderrLevels.contains(record.level);
bool _stdoutFilter(Record record) => !stderrLevels.contains(record.level);

void main() {
  _logger.handler = MultiHandler([
    StreamHandler(stderr, formatter: _defaultFormatter.call)
      ..filter = _stderrFilter,
    StreamHandler(stdout, formatter: _defaultFormatter.call)
      ..filter = _stdoutFilter
  ]);

  _logger.info('This log will be logged to stdout');
  _logger.error('This log will be logged to stderr');
}
