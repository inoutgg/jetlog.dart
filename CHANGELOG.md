# CHANGELOG.md

# 2.0.0

- **BREAKING CHANGE** Package renamed to `strlog`
- **BREAKING CHANGE** `Tracer` renamed to `Timer`
- **BREAKING CHANGE** `Logger.bind` renamed to `Logger.withFields`
- **BREAKING CHANGE** Replaced `Logger.trace` with `Logger.startTimer`
- **BREAKING CHANGE** Changed default level for `Logger.startTimer` from `Level.debug` to `Level.info`
- **BREAKING CHANGE** `Level.danger` and `Level.warning` are renamed to `Level.error` and `Level.warn` respectively
- **BREAKING CHANGE** Removed `JsonFormatter.withIndent`
- Added `Group` field for grouping fields under a namespace without introducing a custom `Obj`
- Added `FileHandler` for file-based logging with optional rotation
- Added `set` method to global logger allowing replacement of the default logger

# 1.0.0

- Added ability to specify custom severity levels when calling `Tracer.stop`
- Added ability to specify additional context fields when calling `Tracer.stop`

# 1.0.0-rc.3

# 1.0.0-rc.2

- **BREAKING CHANGE** Added null-safety

# 1.0.0-rc.1

- **BREAKING CHANGE** Moved predefined logging methods from `Interface` to `DefaultLog` extension.

# 1.0.0-rc.0

- Replaced `trace` level with `debug`, made `Interface#trace` accept optional `level` parameter
- Added `Any` field type that determines field kind based on value type
- Added lazy field evaluation - field values are now evaluated only when accessed
- Changed `Formatter` from abstract class to typedef
- Changed `Filter` from abstract class to typedef
  to support both plain functions and callable classes as filters

## v0.6.0

- `StreamHandler` now throws exceptions for both null stream and null formatter cases
