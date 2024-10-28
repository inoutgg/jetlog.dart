# Handler

Each logger has a handler assigned to it. A logger emits a record and passes it to the handler, which decides how to handle it.

Typically, a handler is associated with a formatter. The formatter formats records passed to the handler and returns the result to the handler so it continues process.

#### Multiple handlers

To assign multiple handlers with a single logger, use `MultiHandler` handler.

```dart
import 'package:strlog/strlog.dart';
import 'package:strlog/handlers.dart' show MultiHandler, StreamHandler, ConsoleHandler;

final logger = Logger.getLogger('docs.multi_handler');

void main() {
  final h = MultiHandler([StreamHandler(...), StreamHandler(...), ..., ConsoleHandler(...)]);
  logger..handler = h;  
}
```
