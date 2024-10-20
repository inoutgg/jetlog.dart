/// This example shows how to setup a logger that delegates logging records
/// to the console (using builtin `print` function) preliminarily formatted
/// with default [TextFormatter].
library example.console;

import 'package:jetlog/formatters.dart' show TextFormatter;
import 'package:jetlog/handlers.dart' show ConsoleHandler;
import 'package:jetlog/jetlog.dart' show DefaultLog, Level, Logger, Str, Obj;
import 'package:jetlog/macros.dart' show Loggable, Field;

@Loggable()
class File {
  File(this.name, this.mime);

  @Field("name")
  final String name;

  @Field("mime")
  final String mime;
}

final _logger = Logger.detached()
  ..level = Level.all
  ..handler = ConsoleHandler(formatter: TextFormatter.withDefaults());

Future<void> main() async {
  final file = File('avatar.png', 'image/png');
  final context = _logger
      .withFields({const Str('username', 'roman-vanesyan'), Obj('file', file)});

  final tracer = context.startTimer('Uploading!', level: Level.info);

  // Emulate uploading, wait for 1 sec.
  await Future<void>.delayed(const Duration(seconds: 1));

  tracer.stop('Aborting...');
  context.fatal('Failed to upload!');
}
