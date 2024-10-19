import 'package:jetlog/formatters.dart';
import 'package:jetlog/global_logger.dart' as logger;
import 'package:jetlog/handlers.dart';
import 'package:jetlog/jetlog.dart' as log;

final _logger = log.Logger.getLogger('jetlog.example')
  ..handler = ConsoleHandler(formatter: JsonFormatter.withDefaults());

void main() async {
  // Set newly created logger as a global one.
  logger.set(_logger);

  logger.info('Greeting', const [log.Str('hello', 'world')]);
}
