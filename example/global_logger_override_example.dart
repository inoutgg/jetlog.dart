import 'package:strlog/formatters.dart';
import 'package:strlog/global_logger.dart' as logger;
import 'package:strlog/handlers.dart';
import 'package:strlog/strlog.dart' as log;

final _logger = log.Logger.getLogger('strlog.example')
  ..handler = ConsoleHandler(formatter: JsonFormatter.withDefaults());

void main() async {
  // Set newly created logger as a global one.
  logger.set(_logger);

  logger.info('Greeting', const [log.Str('hello', 'world')]);
}
