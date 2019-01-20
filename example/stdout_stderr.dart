import 'dart:io' show stdout, stderr;

import 'package:structlog/structlog.dart'
    show Filter, Level, Logger, Record, Str;
import 'package:structlog/handlers.dart' show MultiHandler, StreamHandler;
import 'package:structlog/formatters.dart' show TextFormatter;

class StderrOnlyLevelFilter extends Filter {
  StderrOnlyLevelFilter();

  @override
  bool filter(Record record) =>
      record.level == Level.warning ||
      record.level == Level.danger ||
      record.level == Level.fatal;
}

class StdoutOnlyLevelFilter extends Filter {
  StdoutOnlyLevelFilter();

  @override
  bool filter(Record record) =>
      record.level == Level.trace ||
      record.level == Level.debug ||
      record.level == Level.info;
}

Future<void> main() async {
  final formatter = TextFormatter(
      format: ({name, level, time, message, fields}) =>
          '$name $time [$level]: $message $fields');

  final stderrHandler = StreamHandler(stderr.nonBlocking)
    ..formatter = formatter.bytes
    ..addFilter(StderrOnlyLevelFilter());
  final stdoutHandler = StreamHandler(stdout.nonBlocking)
    ..formatter = formatter.bytes
    ..addFilter(StdoutOnlyLevelFilter());

  final logger = Logger.getLogger('example.stdout')
    ..level = Level.all
    ..handler = MultiHandler([stdoutHandler, stderrHandler]);

  final tracer = logger.bind([
    const Str('username', 'vanesyan'),
    const Str('filename', 'avatar.png'),
    const Str('mime', 'image/png'),
  ]).trace('Uploading!');

  // Emulate uploading, wait for 1 sec.
  await Future<void>.delayed(Duration(seconds: 1));

  tracer.stop('Uploaded!');
}
