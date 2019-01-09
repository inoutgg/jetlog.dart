import 'dart:io' show stdout, stderr;
import 'package:structlog/structlog.dart' show Filter, Level, Logger, Record;
import 'package:structlog/handlers.dart' show StreamHandler;

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
  final stderrHandler = StreamHandler(stderr.nonBlocking)
    ..addFilter(StderrOnlyLevelFilter());
  final stdoutHandler = StreamHandler(stdout.nonBlocking)
    ..addFilter(StdoutOnlyLevelFilter());
  final logger = Logger.getLogger('example.stdout')
    ..addHandler(stderrHandler)
    ..addHandler(stdoutHandler);

  final tracer = logger
      .bind((collector) => collector
        ..addString('username', 'vanesyan')
        ..addString('filename', 'avatar.png')
        ..addString('mime', 'image/png'))
      .trace('Uploading!');

  // Emulate uploading, wait for 1 sec.
  await Future<void>.delayed(Duration(seconds: 1));

  tracer.stop('Uploaded!');
}
