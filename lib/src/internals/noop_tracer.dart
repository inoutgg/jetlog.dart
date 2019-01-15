import 'package:structlog/src/tracer.dart';

class NoopTracerImpl implements Tracer {
  @override
  void stop(String message) {}
}
