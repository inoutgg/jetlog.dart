# CHANGELOG.md
# 0.7.0
* `Filter` now is typedef rather than abstract class.
  It allows plain functions to be used as filters as well as callable classes.
* Introduce lazy logging context used to postpone evaluation of messages. Add `lazy` getter to `Interface` abstract
  class a such both bound logging context and `Logger` expose it too.

```dart
void main() {
  logger.lazy.info(() => 'Hello world!'); // evaluation postponed until use
}
```

## v0.6.0
* `StreamHandler` throws on `null` stream as well as `null` formatter.
