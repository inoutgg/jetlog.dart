import 'dart:async' show Future;
import 'dart:io' show stdout, stderr;

import 'package:jetlog/jetlog.dart' show Level, Logger, Record, Str;
import 'package:jetlog/handlers.dart' show MultiHandler, StreamHandler;
import 'package:jetlog/formatters.dart' show TextFormatter;

bool _stderrOnlyFilter(Record record) =>
    record.level == Level.warning ||
    record.level == Level.danger ||
    record.level == Level.fatal;

@override
bool _stdoutOnlyFilter(Record record) =>
    record.level == Level.trace ||
    record.level == Level.debug ||
    record.level == Level.info;

final _stderrHandler =
    StreamHandler(stderr, formatter: TextFormatter.defaultFormatter)
      ..filter = _stderrOnlyFilter;
final _stdoutHandler =
    StreamHandler(stdout, formatter: TextFormatter.defaultFormatter)
      ..filter = _stdoutOnlyFilter;

Future<void> main() async {
  final logger = Logger.getLogger('example.stdout')
    ..level = Level.all
    ..handler = MultiHandler([_stdoutHandler, _stderrHandler]);

  final context = logger.bind({
    const Str('username', 'vanesyan'),
    const Str('filename', 'avatar.png'),
    const Str('mime', 'image/png'),
  });
  final tracer = context.trace('Uploading!');

  // Emulate uploading, wait for 1 sec.
  await Future<void>.delayed(Duration(seconds: 1));

  tracer.stop('Aborting...');
  context.fatal('Failed to upload!');
}
