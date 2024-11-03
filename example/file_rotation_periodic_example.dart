library;

import 'dart:math' show Random;

import 'package:strlog/formatters.dart' show TextFormatter;
import 'package:strlog/global_logger.dart' as log;
import 'package:strlog/strlog.dart';
import 'package:strlog/handlers.dart' show FileHandler, LogFileRotationPolicy;

final formatter = TextFormatter.withDefaults();
final handler = FileHandler(
    LogFileRotationPolicy.periodic(Duration(seconds: 30)), // each 30 seconds
    path: './file_rotation_periodic_example.log',
    formatter: formatter.call);
final _logger = Logger.detached()
  ..handler = handler
  ..level = Level.all;

Future<void> main() async {
  log.set(_logger);

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
  var cooldown = Duration(seconds: 0);
  for (int attempt = 1; attempt <= maxAttempts; attempt++) {
    await Future<void>.delayed(cooldown);

    try {
      final attemptTimer = context.withFields({
        Int('attempt', attempt),
      }).startTimer('Attempt to upload...', level: Level.debug);

      await Future<void>.delayed(Duration(seconds: Random().nextInt(5)));
      cooldown = Duration(seconds: attempt);

      // resolve on the last attempt.
      if (attempt != maxAttempts) {
        attemptTimer.stop('Failed to upload!',
            level: Level.warn,
            fields: {Int('attempt', attempt), Dur('next_cooldown', cooldown)});

        throw Exception('Upload failed');
      }

      attemptTimer.stop('Upload succeeded!');

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
