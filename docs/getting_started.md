# Getting started
**This page is a quick overview of structlog.**

structlog is compact and robust structured logger for Dart. Its main adventure
over string based loggers - ???

## Installation guide

structlog is available as a package under the `structlog` name on Dart public
package registry, and, therefore can easily be installed using `pub`:

```bash
$ pub install structlog
```

Now you can freely use it in your code where it's necessary.

## Quick start

structlog seperates logging process into 3 steps: emitting, handling and
formatting. Each step is isolated (in terms of configuration) from other and
can be configured in either way.

Lets see a simple example

```dart
import 'dart:io' show stdout;
import 'package:structlog/structlog.dart' show Logger;
import 'package:structlog/handlers.dart' show StreamHandler;
import 'package:structlog/formatters.dart';

// 1. Formatting
final formatter = Formatter.of([
  // TODO???
]);

// 2. Handling
final stdoutHandler = StreamHandler(stdout.nonBlocking)..formatter = formatter;

// 3. Logger itself
final logger = Logger
  .getLogger('example.quick_start')
  ..addHandler(stdoutHandler);
```

Here we configure a new logger instance with `example.quick_start` name that
sends all records to the `stdout`.

Lets build a new logging context with bound field set

```dart
final context = logger.bind((collector) =>
  collector
    ..addString('hello', 'world')
    ..addBool('done', true)
);
```

And log some message using it

```dart
context.info('Complete!');
```

To dive deeper see ???.
