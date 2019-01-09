import 'package:structlog/src/tracer.dart';

class NoopTracer implements Tracer {
  @override
  void stop(String message) { /* noop */ }
}
