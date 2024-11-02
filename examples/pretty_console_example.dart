/// This examples show how to setup prettified console logger.
library;

import 'package:ansicolor/ansicolor.dart' show AnsiPen;
import 'package:strlog/formatters.dart' show TextFormatter;
import 'package:strlog/handlers.dart' show ConsoleHandler;
import 'package:strlog/strlog.dart' show DefaultLog, Level, Logger, Str, Group;

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
  var context = _logger.withFields({
    const Str('username', 'roman-vanesyan'),
  });

  context.info('Received upload request');

  // Create a new logging context
  context = context.withFields({
    const Group('file', [
      Str('name', 'avatar.png'),
      Str('mime', 'image/png'),
    ])
  });

  final timer = context.startTimer('Uploading!');

  // Emulate uploading, wait for 1 sec.
  await Future<void>.delayed(const Duration(seconds: 1));

  timer.stop('Aborting...');
  context.error('Failed to upload!', {const Str('reason', 'Timeout')});
}
