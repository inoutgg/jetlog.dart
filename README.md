# jetlog &middot; [![Test Status][cirrusci-image]][cirrusci-url] [![Code Coveraege][codecov-image]][codecov-url]
Fast, structured, leveled logging for Dart.

jetlog's API is designed to provide great development experience
without losing performance. jetlog allows to format logging records
into different representations and supports formatting to JSON and text
out of the box.

There are a couple of other features developer may benefit from:
* Blazing fast logging
* Efficient logging of structured data
* Unambiguous support for loggers hierarchy
* Exchangeable logging handlers
* Logging filters

## Installation
To get mostly up to date package install it through `pub`.

`pub get jetlog`

## Getting started
The easiest way to get up and running is to use global logger provided
in `global_logger` package library.

```dart
import 'package:jetlog/global_logger.dart' as logger;
import 'package:jetlog/jetlog.dart' as log show Str;

void main() async {
  logger.bind({
    const log.Str('hello', 'world')
  }).info('Greeting');
}

// => '2019-06-27 15:37:38.046859 [INFO]: Greeting hello=world'
```

## License
Released under the [MIT] license.

[MIT]: ./LICENSE
[cirrusci-image]: https://api.cirrus-ci.com/github/vanesyan/jetlog.dart.svg?branch=master
[cirrusci-url]: https://cirrus-ci.com/github/vanesyan/jetlog.dart
[codecov-image]: https://codecov.io/gh/vanesyan/jetlog.dart/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/vanesyan/jetlog.dart
