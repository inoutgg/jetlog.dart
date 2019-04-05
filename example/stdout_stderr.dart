import 'dart:async' show Future;
import 'dart:io' show stdout, stderr;

import 'package:structlog/structlog.dart'
    show Filter, Level, Logger, Record, Str;
import 'package:structlog/handlers.dart' show MultiHandler, StreamHandler;
import 'package:structlog/formatters.dart' show TextFormatter;

class _StderrOnlyLevelFilter extends Filter {
  _StderrOnlyLevelFilter();

  @override
  bool filter(Record record) =>
      record.level == Level.warning ||
      record.level == Level.danger ||
      record.level == Level.fatal;
}

class _StdoutOnlyLevelFilter extends Filter {
  _StdoutOnlyLevelFilter();

  @override
  bool filter(Record record) =>
      record.level == Level.trace ||
      record.level == Level.debug ||
      record.level == Level.info;
}

final _formatter = TextFormatter(
    format: ({name, level, time, message, fields}) =>
        '$name $time [$level]: $message $fields');

final _stderrHandler = StreamHandler(stderr.nonBlocking)
  ..formatter = _formatter.asBytesFormatter
  ..addFilter(_StderrOnlyLevelFilter());
final _stdoutHandler = StreamHandler(stdout.nonBlocking)
  ..formatter = _formatter.asBytesFormatter
  ..addFilter(_StdoutOnlyLevelFilter());

final _logger = Logger.getLogger('example.stdout')
  ..level = Level.all
  ..handler = MultiHandler([_stdoutHandler, _stderrHandler]);

Future<void> main() async {
  final tracer = _logger.bind([
    const Str('username', 'vanesyan'),
    const Str('filename', 'avatar.png'),
    const Str('mime', 'image/png'),
  ]).trace('Uploading!');

  // Emulate uploading, wait for 1 sec.
  await Future<void>.delayed(Duration(seconds: 1));

  tracer.stop('Uploaded!');
}
