/// This example demonstrates a simple hierarchy of loggers.
/// All child loggers of the logger with the `strlog.example.hierarchy` namespace
/// should propagate records to it, resulting in all records from child loggers
/// being logged to the console.
library;

import 'package:strlog/strlog.dart' show Logger, DefaultLog, Str;
import 'package:strlog/handlers.dart' show ConsoleHandler;
import 'package:strlog/formatters.dart' show TextFormatter;
import './get_user.dart';

void main() {
  // Define logger namespace
  final logger = Logger.getLogger('strlog.example.hierarchy')
    ..handler = ConsoleHandler(formatter: TextFormatter.withDefaults().call);

  final user = getUser();

  logger.info('User email', {Str('user_email', user.email)});
}
