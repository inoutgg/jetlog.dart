# CHANGELOG.md
# 1.0.0
* Add ability to specify custom severity level on `Tracer.stop` call.
* Add ability to specify additional context fields on `Tracer.stop` call.

# 1.0.0-rc.3
# 1.0.0-rc.2
* **BREAKING CHANGE** Null-safety

# 1.0.0-rc.1
* **BREAKING CHANGE** Extract predefined logging methods from `Interface` to `DefaultLog` extension.

# 1.0.0-rc.0
* Drop `trace` level in favor of `debug`, make `Interface#trace` to accept `level` as optional second parameter.
* Introduce `Any` field, a special field kind of which is determined based on
`value`'s type probation.
* Introduce lazy fields, i.e. fields values of which are evaluated on access.
* `Formatter` now is typedef rather than abstract class.
* `Filter` now is typedef rather than abstract class.
  It allows plain functions to be used as filters as well as callable classes.

## v0.6.0
* `StreamHandler` throws on `null` stream as well as `null` formatter.
