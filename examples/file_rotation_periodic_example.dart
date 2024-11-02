library;

import 'package:strlog/formatters.dart' show TextFormatter;
import 'package:strlog/global_logger.dart' as log;
import 'package:strlog/strlog.dart';
import 'package:strlog/handlers.dart' show FileHandler, LogFileRotationPolicy;

final formatter = TextFormatter.withDefaults();
final handler = FileHandler(
    LogFileRotationPolicy.periodic(Duration(seconds: 30)), // each 30seconds
    path: './file_rotation_periodic_example.log',
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

  // Emulate exponential backoff retry
  final maxAttempts = 5;
  for (int attempt = 0; attempt < maxAttempts; attempt++) {
    try {
      await Future<void>.delayed(Duration(seconds: 10 * (attempt + 1)));

      // resolve on the last attempt.
      if (attempt != maxAttempts - 1) {
        context
            .error('Failed to upload, retrying...', {Int('attempt', attempt)});
        throw Exception('failed');
      }

      break; // Success, exit loop
    } catch (e) {
      timer.stop('Aborting...');
      context.fatal('Failed to upload!', {const Str('reason', 'Timeout')});

      if (attempt == maxAttempts - 1) rethrow; // Last attempt failed
    }

    timer.stop('Uploaded!');
  }
}
