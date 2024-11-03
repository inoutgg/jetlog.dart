# Recipes

### Forward error logs to stderr, while the rest to stdout

To split logging of records between stderr and stdout, we basically need two constructions provided out of the box by strlog: `Filter` and `MultiHandler`.

```dart
import 'dart:io' show stderr, stdout;
import 'package:strlog/formatters.dart';
import 'package:strlog/handlers.dart';
import 'package:strlog/strlog.dart';

final _logger = Logger.detached();
final _defaultFormatter = TextFormatter.withDefaults();
final stderrLevels = {Level.warn, Level.error, Level.fatal};

bool _stderrFilter(Record record) => stderrLevels.contains(record.level);
bool _stdoutFilter(Record record) => !stderrLevels.contains(record.level);

void main() {
  _logger.handler = MultiHandler([
    // Forward logs to stderr
    StreamHandler(stderr, formatter: _defaultFormatter)..filter = _stderrFilter,
    
    // Forward logs to stdout
    StreamHandler(stdout, formatter: _defaultFormatter)..filter = _stdoutFilter
  ]);

  _logger.info("This log will be logged to stdout");  // stdout
  _logger.error("This log will be logged to stderr"); // stderr
}
```
