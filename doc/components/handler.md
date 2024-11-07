# Handler

Each logger has a handler assigned to it. A logger emits a record and passes it to the handler, which decides how to handle it.

Typically, a handler is associated with a formatter. The formatter formats records passed to the handler and returns the result to the handler so it continues process.

strlog comes with a bunch of handlers bundled.

## ConsoleHandler

`ConsoleHandler` is used to output records to the console. It processes incoming records by utilizing Dart's built-in `print` function to display them.

## FileHandler

`FileHandler` is used to output records to a file. 


## MultiHandler

`MultiHandler` allows multiple handlers to be combined into a single `Handler` interface. It receives multiple handlers and broadcasts incoming records to each of them.

```dart
import 'package:strlog/strlog.dart';
import 'package:strlog/handlers.dart' show MultiHandler, StreamHandler, ConsoleHandler;

final logger = Logger.getLogger('strlog.examples.multi_handler');

void main() {
  final h = MultiHandler([
    StreamHandler(...),
    StreamHandler(...),
    ...,
    ConsoleHandler(...)
  ]);
  logger.handler = h;
}
```
