# Getting started

Requirements:

* Dart 3.0.0 or greater (check out [dart-overlay.nix](https://github.com/roman-vanesyan/dart-overlay.nix) if you use Nix)

### Installation

To start using `jetlog` add the package via `pub`

```shell-session
dart pub add jetlog
```

### Hello world

The simplest way to get started with the jetlog is by using a global logger

```dart
import 'package:jetlog/global_logger.dart' as log;
import 'package:jetlog/jetlog.dart';

void main() {
    log.info('Greeting', const [Str('who', 'world'), Str('what', 'hello')]);
}
```

```log
2024-10-14 22:11:16.927220 [INFO]: Hello world who=world what=hello
```

### Set up the logger

```dart
import 'dart:io';

import 'package:jetlog/jetlog.dart';
import 'package:jetlog/handlers.dart';
import 'package:jetlog/formatters.dart';

final _defaultFormatter = TextFormatter.withDefaults();

void main() {
    final logger = Logger.detached()..handler = ConsoleHandler(formatter: _defaultFormatter); 

    logger.info('A new log with bound PID appears on a screen', [Int('pid', pid)]);
}
```

Check out [reference documentation](https://pub.dev/documentation/jetlog) for a detailed overview of the API.
