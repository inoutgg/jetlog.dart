import 'package:jetlog/jetlog.dart';
import 'package:jetlog/formatters.dart' show TextFormatter;
import 'package:jetlog/handlers.dart' show ConsoleHandler;

void main() {
  final logger = Logger.getLogger('example.lazy')
    ..handler = ConsoleHandler(formatter: TextFormatter.defaultFormatter);

  logger.lazy.info(() => 'Hello world!');
}
