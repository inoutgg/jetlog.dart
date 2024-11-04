import 'package:strlog/strlog.dart' show Logger;
import 'package:strlog/handlers.dart' show ConsoleHandler;
import 'package:strlog/formatters.dart' show TextFormatter;

// Define logger namespace
final logger = Logger.getLogger('strlog.example.hierarchy')
  ..handler = ConsoleHandler(formatter: TextFormatter.withDefaults().call);
