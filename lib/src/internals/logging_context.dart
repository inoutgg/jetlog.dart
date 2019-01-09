import 'package:structlog/src/field.dart';
import 'package:structlog/src/level.dart';
import 'package:structlog/src/interface.dart';
import 'package:structlog/src/tracer.dart';
import 'package:structlog/src/internals/fieldset.dart';
import 'package:structlog/src/internals/tracer.dart';
import 'package:structlog/src/internals/record.dart';
import 'package:structlog/src/internals/logger.dart';

class LoggingContext implements Interface {
  LoggingContext(this._logger, [this._fields]);

  final LoggerImpl _logger;
  final FieldSet _fields;

  @override
  void log(Level level, String message) {
    final record = RecordImpl(
        name: _logger.name, level: level, message: message, fields: _fields);

    _logger.add(record);
  }

  @override
  void debug(String message) => log(Level.debug, message);

  @override
  Tracer trace(String message) {
    log(Level.trace, message);

    return TracerImpl(this);
  }

  @override
  void info(String message) => log(Level.info, message);

  @override
  void warning(String message) => log(Level.warning, message);

  @override
  void danger(String message) => log(Level.danger, message);

  @override
  void fatal(String message) => log(Level.fatal, message);

  @override
  Interface bind(FieldSetCollectorCallback collect) {
    final builder = FieldSetBuilder();

    collect(builder);

    final fields = builder.build();

    if (_fields != null) {
      fields.addAll(_fields);
    }

    return LoggingContext(_logger, fields);
  }
}
