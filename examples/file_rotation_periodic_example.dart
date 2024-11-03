library;

import 'package:strlog/formatters.dart' show TextFormatter;
import 'package:strlog/global_logger.dart' as log;
import 'package:strlog/strlog.dart';
import 'package:strlog/handlers.dart' show FileHandler, LogFileRotationPolicy;

final formatter = TextFormatter.withDefaults();
final handler = FileHandler(
    LogFileRotationPolicy.periodic(Duration(seconds: 30)), // each 30 seconds
    path: './file_rotation_periodic_example.log',
    formatter: formatter.call);
final logger = Logger.detached()
  ..handler = handler
  ..level = Level.all;

Future<void> main() async {
  log.set(logger);

  final context = log.withFields({
    const Str('username', 'roman-vanesyan'),
    const Group('file', [
      Str('name', 'avatar.png'),
      Str('mime', 'image/png'),
    ])
  });

  final uploadingTimer = context.startTimer('Uploading!', level: Level.info);

  // Emulate exponential backoff retry
  final maxAttempts = 5;
  for (int attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      final attemptTimer = context.withFields({
        Int('attempt', attempt),
      }).startTimer('Uploading attempt', level: Level.debug);

      final waitFor = Duration(seconds: (2.5 * attempt).toInt());
      await Future<void>.delayed(waitFor);

      // resolve on the last attempt.
      if (attempt != maxAttempts) {
        attemptTimer.stop('Failed attempt');
        context.warn('Failed to upload, retrying...',
            {Int('attempt', attempt), Dur('waited_for', waitFor)});

        throw Exception('failed');
      }

      attemptTimer.stop('Succeeded');

      break; // Success, exit loop
    } catch (e) {
      if (attempt == maxAttempts) {
        uploadingTimer.stop('Aborting...');
        context.error('Failed to upload!', {const Str('reason', 'Timeout')});

        rethrow; // Last attempt failed
      }
    }
  }

  uploadingTimer.stop('Uploaded!');
}
