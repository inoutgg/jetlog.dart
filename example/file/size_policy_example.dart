library example.file.sized_policy;

import 'package:jetlog/formatters.dart' show TextFormatter;
import 'package:jetlog/handlers.dart' show FileHandler, RotationPolicy;
import 'package:jetlog/jetlog.dart' show Level, Logger, Str, DefaultLog;

final _logger = Logger.detached()
  ..level = Level.all
  ..handler = FileHandler(Uri.file('./logfile.log'),
<<<<<<< HEAD
      rotationPolicy: const RotationPolicy.sized(maxSize: 1024), // in bytes
      maxBackUps: 100,
      formatter: TextFormatter.defaultFormatter);
||||||| parent of 73f9b03 (refactor: various improvements to the file handler (need tests))
      rotationPolicy: const RotationPolicy.sized(maxSize: 1024 * 1000), // in bytes
      maxBackUps: 100,
      formatter: TextFormatter.withDefaults());
=======
      rotationPolicy: const RotationPolicy.sized(1024 * 1000), // in bytes
      maxBackUps: 5,
      formatter: TextFormatter.withDefaults());
>>>>>>> 73f9b03 (refactor: various improvements to the file handler (need tests))

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
  for (int i = 0; i < 10000; i++) {
    context.fatal('Failed to upload $i!');
  }
}
