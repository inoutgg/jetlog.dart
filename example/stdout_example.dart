import 'dart:async' show Future;
import 'dart:io' show stdout, stderr;

import 'package:jetlog/jetlog.dart'
    show Filter, Level, Logger, Record, Str;
import 'package:jetlog/handlers.dart' show MultiHandler, StreamHandler;
import 'package:jetlog/formatters.dart' show TextFormatter;

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

final _stderrHandler =
    StreamHandler(stderr, formatter: TextFormatter.defaultFormatter)
      ..filter = _StderrOnlyLevelFilter();
final _stdoutHandler =
    StreamHandler(stdout, formatter: TextFormatter.defaultFormatter)
      ..filter = _StdoutOnlyLevelFilter();

final _logger = Logger.getLogger('example.stdout')
  ..level = Level.all
  ..handler = MultiHandler([_stdoutHandler, _stderrHandler]);

Future<void> main() async {
  final context = _logger.bind({
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
