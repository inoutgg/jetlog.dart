/// This example shows how to setup a logger that delegates logging records
/// to the console (using builtin `print` function) preliminarily formatted
/// with default [TextFormatter].
library example.console;

import 'package:jetlog/formatters.dart' show TextFormatter;
import 'package:jetlog/handlers.dart' show ConsoleHandler;
import 'package:jetlog/jetlog.dart' show DefaultLog, Level, Logger, Str, Group;

final _logger = Logger.detached()
  ..level = Level.all
  ..handler = ConsoleHandler(formatter: TextFormatter.withDefaults());

Future<void> main() async {
  final context = _logger.withFields({
    const Str('username', 'roman-vanesyan'),
    const Group('file', [
      Str('name', 'avatar.png'),
      Str('mime', 'image/png'),
    ])
  });

  final tracer = context.startTimer('Uploading!', level: Level.info);

  // Emulate uploading, wait for 1 sec.
  await Future<void>.delayed(const Duration(seconds: 1));

  tracer.stop('Aborting...');
  context.fatal('Failed to upload!', {const Str('reason', 'Timeout')});
}
