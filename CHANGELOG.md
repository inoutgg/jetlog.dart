# CHANGELOG.md
# 1.0.0-rc.0
* Introduce `Any` field, a special field kind of which is determined based on
`value`'s type probation.
* Introduce lazy fields, i.e. fields values of which are evaluated on access.
* `Formatter` now is typedef rather than abstract class.
* `Filter` now is typedef rather than abstract class.
  It allows plain functions to be used as filters as well as callable classes.

## v0.6.0
* `StreamHandler` throws on `null` stream as well as `null` formatter.
