# strlog &middot; [![Test Status][gh-actions-image]][gh-actions-url]

![strlog.dart demo][DEMO]

Structured, hierarchical, leveled logging for Dart.

Features:

- Built-in primitives for bound structured record context
- Leveled records
- Built-in configurable text and JSON log formatters
- Built-in support for filtering records
- Dozens of log record handlers out of the box

The strlog package exposes three types of loggers: hierarchical, detached, and noop loggers.

A hierarchical logger is a tree-like logging structure allowing child loggers to forward records to higher-level loggers, all the way up to the highest-level logger, i.e., the root logger. The hierarchy of loggers is defined based on the logger name. The name represents a dot-separated string, where each part defines a hierarchy level.

In contrast, a detached logger is a hierarchy-free logger, meaning that it does not have a parent or children.

Lastly, a noop logger discards any records it receives.

## Usage

Use `dart pub` to get the package:

```sh
$ dart pub add strlog
```

Once the package is installed, it's ready to be used.

### Getting started

The easiest way to start logging records is to use the global logger provided in the `global_logger` package library. The global logger comes preconfigured to print logs to the console using `print`.

```dart
import 'package:strlog/global_logger.dart' as logger;
import 'package:strlog/strlog.dart' as log;

void main() async {
  logger.info('Greeting', const [log.Str('hello', 'world')]);
}

// => '2019-06-27 15:37:38.046859 [INFO]: Greeting hello=world'
```

To override the default logger, you can use the `set` function exposed by the global_logger package:

```dart
import 'package:strlog/formatters.dart';
import 'package:strlog/global_logger.dart' as logger;
import 'package:strlog/handlers.dart';
import 'package:strlog/strlog.dart' as log;

final handler = ConsoleHandler(formatter: JsonFormatter.withDefaults());
final _logger = log.Logger.getLogger('strlog.example')..handler = handler;

void main() async {
  // Set the newly created logger as the global one.
  logger.set(_logger);

  logger.info('Greeting', const [log.Str('hello', 'world')]);

  await handler.close();
}
```

For more detailed information, check out the documentation at [strlog.inout.gg](https://strlog.inout.gg).

## License

Released under the [MIT] license.

[MIT]: ./LICENSE
[gh-actions-image]: https://github.com/inoutgg/strlog.dart/workflows/test/badge.svg
[gh-actions-url]: https://github.com/inoutgg/strlog.dart
[DEMO]: ./docs/assets/demo.gif
