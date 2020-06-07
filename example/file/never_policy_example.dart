library example.file.never_policy;

import 'package:jetlog/formatters.dart' show TextFormatter;
import 'package:jetlog/handlers.dart' show FileHandler;
import 'package:jetlog/jetlog.dart' show Level, Logger, Str, DefaultLog;

final _logger = Logger.detached()
  ..level = Level.all
  ..handler = FileHandler(Uri.file('./file.log'),
      formatter: TextFormatter.defaultFormatter);

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
