/// This example shows how to setup a logger that delegates logging records
/// either to `stdout` or `stderr` based on severity level of the emitted record.
library example.complex;

import 'dart:async' show Future;
import 'dart:io' show stdout, stderr;

import 'package:jetlog/formatters.dart' show TextFormatter;
import 'package:jetlog/handlers.dart' show MultiHandler, StreamHandler;
import 'package:jetlog/jetlog.dart' show Level, Logger, Record, Str, DefaultLog;

bool _stderrOnlyFilter(Record record) =>
    record.level == Level.warning ||
    record.level == Level.danger ||
    record.level == Level.fatal;

@override
bool _stdoutOnlyFilter(Record record) =>
    record.level == Level.debug || record.level == Level.info;

final _stderrHandler =
    StreamHandler(stderr, formatter: TextFormatter.withDefaults())
      ..filter = _stderrOnlyFilter;
final _stdoutHandler =
    StreamHandler(stdout, formatter: TextFormatter.withDefaults())
      ..filter = _stdoutOnlyFilter;

final _logger = Logger.getLogger('example.stdout')
  ..level = Level.all
  ..handler = MultiHandler([_stdoutHandler, _stderrHandler]);

Future<void> main() async {
  final context = _logger.bind({
    const Str('username', 'vanesyan'),
    const Str('filename', 'avatar.png'),
    const Str('mime', 'image/png'),
  });

  final tracer = context.startTimer('Uploading!', level: Level.info);

  // Emulate uploading, wait for 1 sec.
  await Future<void>.delayed(const Duration(seconds: 1));

  tracer.stop('Aborting...');
  context.fatal('Failed to upload!');
}
