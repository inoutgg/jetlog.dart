library;

import 'package:strlog/formatters.dart' show TextFormatter;
import 'package:strlog/global_logger.dart' as log;
import 'package:strlog/strlog.dart';
import 'package:strlog/handlers.dart' show FileHandler, LogFileRotationPolicy;

final formatter = TextFormatter.withDefaults();
final handler = FileHandler(
    LogFileRotationPolicy.union([
      LogFileRotationPolicy.periodic(Duration(minutes: 5)), // each 5 minutes
      LogFileRotationPolicy.sized(1024 * 1024) // if exceeds 1mb.
    ]),
    formatter: formatter.call);

final logger = Logger.detached()..handler = handler;

Future<void> main() async {
  log.set(logger);

  final context = log.withFields({
    const Str('username', 'roman-vanesyan'),
    const Group('file', [
      Str('name', 'avatar.png'),
      Str('mime', 'image/png'),
    ])
  });

  final timer = context.startTimer('Uploading!', level: Level.info);

  // Emulate uploading, wait for 1 sec.
  await Future<void>.delayed(const Duration(seconds: 1));

  timer.stop('Aborting...');
  context.fatal('Failed to upload!', {const Str('reason', 'Timeout')});

  // close handler.
  await handler.close();
}
