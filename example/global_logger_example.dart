/// This example shows how to use a global logger.
library example.global_logger;

import 'package:strlog/global_logger.dart' as log;
import 'package:strlog/strlog.dart';

Future<void> main() async {
  final context = log.withFields({
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
