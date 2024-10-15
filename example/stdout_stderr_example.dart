import 'dart:io' show stderr, stdout;
import 'package:jetlog/formatters.dart';
import 'package:jetlog/handlers.dart';
import 'package:jetlog/jetlog.dart';

final _logger = Logger.detached();
final _defaultFormatter = TextFormatter.withDefaults();
final stderrLevels = {Level.warn, Level.error, Level.fatal};

bool _stderrFilter(Record record) => stderrLevels.contains(record.level);
bool _stdoutFilter(Record record) => !stderrLevels.contains(record.level);

void main() {
  _logger.handler = MultiHandler([
    StreamHandler(stderr, formatter: _defaultFormatter)..filter = _stderrFilter,
    StreamHandler(stdout, formatter: _defaultFormatter)..filter = _stdoutFilter
  ]);

  _logger.info("This log will be logged to stdout");
  _logger.error("This log will be logged to stderr");
}
