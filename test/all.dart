import 'console_handler_test.dart' as console_handler_test;
import 'field_test.dart' as field_test;
import 'formatter_test.dart' as formatter_test;
import 'interface_test.dart' as interface_test;
import 'json_formatter_test.dart' as json_formatter_test;
import 'level_test.dart' as level_test;
import 'logger_test.dart' as logger_test;
import 'multi_filter_test.dart' as multi_filter_test;
import 'multi_handler_test.dart' as multi_handler_test;
import 'stream_handler_test.dart' as stream_handler_test;
import 'text_formatter_test.dart' as text_formatter_test;
import 'tracer_test.dart' as tracer_test;

void main() {
  // Core tests
  level_test.main();
  field_test.main();
  formatter_test.main();
  interface_test.main();
  logger_test.main();
  tracer_test.main();

  // Filters tests
  multi_filter_test.main();

  // Formatters tests
  json_formatter_test.main();
  text_formatter_test.main();

  // Handlers tests
  console_handler_test.main();
  multi_handler_test.main();
  stream_handler_test.main();
}
