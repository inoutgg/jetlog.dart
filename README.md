# jetlog &middot; [![Test Status][gh-actions-image]][gh-actions-url] [![Code Coveraege][codecov-image]][codecov-url]
Fast, structured, leveled logging for Dart.

jetlog's API is designed to provide great development experience
without losing performance. jetlog allows to format logging records
into different representations and supports formatting to JSON and text
out of the box.

There are a couple of features developer may benefit from:
* Blazing fast logging
* Efficient logging of structured data (with support to lazy evaluation)
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
[gh-actions-image]: https://github.com/vanesyan/jetlog.dart/workflows/test/badge.svg
[gh-actions-url]: https://github.com/vanesyan/jetlog.dart
[codecov-image]: https://codecov.io/gh/vanesyan/jetlog.dart/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/vanesyan/jetlog.dart
