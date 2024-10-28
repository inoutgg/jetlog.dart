/// This example shows how to setup a logger to log to console.
library example.console;

import 'package:strlog/formatters.dart' show TextFormatter;
import 'package:strlog/handlers.dart' show ConsoleHandler;
import 'package:strlog/strlog.dart' show DefaultLog, Level, Logger, Str, Group;

final _logger = Logger.detached()
  ..level = Level.all
  ..handler = ConsoleHandler(formatter: TextFormatter.withDefaults());

Future<void> main() async {
  // Create a new logging context
  final context = _logger.withFields({
    const Str('username', 'roman-vanesyan'),
    const Group('file', [
      Str('name', 'avatar.png'),
      Str('mime', 'image/png'),
    ])
  });

  final tracer = context.startTimer('Uploading!');

  // Emulate uploading, wait for 1 sec.
  await Future<void>.delayed(const Duration(seconds: 1));

  tracer.stop('Aborting...');
  context.fatal('Failed to upload!', {const Str('reason', 'Timeout')});
}
