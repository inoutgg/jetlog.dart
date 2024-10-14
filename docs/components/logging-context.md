# Logging context

A logging context is an object that carries a set of fields that is bound to every single log emitted. It is one of the core concepts of the jetlog logger.

When a new logger instance is created via

```dart
Logger(...);
Logger.detach(...);
```

&#x20;an implicit empty logging context is created under the hood.

The logging context is what creates a new log records that later delegated to a handler.

To create a new instance of the context with bound set of fields, use `logger.withFields(...)`.
