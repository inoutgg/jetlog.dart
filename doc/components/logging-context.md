# Logging context

A logging context is an object that carries a set of fields that are bound to every single log emitted. It is one of the core concepts of the strlog logger.

When a new logger instance is created via

```dart
Logger.getLogger(...);
Logger.detach(...);
```

an implicit logging context is created under the hood.

The logging context creates new log records that are later delegated to a handler. Each emitted record carries a set of logging context's bound fields.

To create a new instance of the context with a bound set of fields, use

```dart
logger.withFields(...);
```
