/// This example shows how to setup a prettified console logger.
library;

import 'dart:math' show Random;

import 'package:ansicolor/ansicolor.dart' show AnsiPen;
import 'package:strlog/formatters.dart' show TextFormatter;
import 'package:strlog/handlers.dart' show ConsoleHandler;
import 'package:strlog/strlog.dart';
import 'package:strlog/global_logger.dart' as log;

class _Ansi {
  static final boldBlack = AnsiPen()..black(bold: true);
  static final _red = AnsiPen()..red(bold: true);
  static final _yellow = AnsiPen()..yellow(bold: true);
  static final _blue = AnsiPen()..blue(bold: true);
  static final _cyan = AnsiPen()..cyan(bold: true);

  // Coloring level.
  static String level(Level level) {
    final name = level.name.padRight(5);
    return switch (level) {
      Level.debug => _cyan(name),
      Level.info => _blue(name),
      Level.warn => _yellow(name),
      Level.error => _red(name),
      Level.fatal => _red(name),
      _ => name
    };
  }

  // Format time in yyyy-mm-dd hh:mm:ss format.
  static String ts(DateTime t) {
    final year = t.year.toString().padLeft(4, '0');
    final month = t.month.toString().padLeft(2, '0');
    final day = t.day.toString().padLeft(2, '0');
    final hour = t.hour.toString().padLeft(2, '0');
    final minute = t.minute.toString().padLeft(2, '0');
    final second = t.second.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute:$second';
  }
}

final formatter = TextFormatter(
    (name, timestamp, level, message, fields) =>
        '$name $timestamp [${level.padLeft(6)}]: ${message.padRight(32)} ${_Ansi.boldBlack(fields)}'
            .trim(),
    formatLevel: _Ansi.level,
    formatTimestamp: _Ansi.ts);
final handler = ConsoleHandler(formatter: formatter.call);
final _logger = Logger.detached()
  ..level = Level.all
  ..handler = handler;

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
