/// This example shows how to setup a logger that delegates logging records
/// to the console (using builtin `print` function) preliminarily formatted
/// with default [TextFormatter].
library example.console;

import 'package:jetlog/formatters.dart' show TextFormatter;
import 'package:jetlog/handlers.dart' show ConsoleHandler;
import 'package:jetlog/jetlog.dart'
    show DefaultLog, Level, Logger, Str;

final _logger = Logger.detached()
  ..level = Level.all
  ..handler = ConsoleHandler(formatter: TextFormatter.withDefaults());

Future<void> main() async {
  final context = _logger.bind({
    const Str('username', 'vanesyan'),
    const Str('filename', 'avatar.png'),
    const Str('mime', 'image/png'),
  });

  final tracer = context.trace('Uploading!', Level.info);

  // Emulate uploading, wait for 1 sec.
  await Future<void>.delayed(const Duration(seconds: 1));

  tracer.stop('Aborting...');
  context.fatal('Failed to upload!');
}
