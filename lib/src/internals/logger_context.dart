import 'package:structlog/src/field.dart';
import 'package:structlog/src/interface.dart';
import 'package:structlog/src/internals/logger.dart';
import 'package:structlog/src/internals/record.dart';
import 'package:structlog/src/internals/tracer.dart';
import 'package:structlog/src/level.dart';
import 'package:structlog/src/tracer.dart';

class LoggerContext implements Interface {
  LoggerContext(this._logger, [this._fields]);

  final LoggerImpl _logger;
  final Set<Field> _fields;

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
  Interface bind(Iterable<Field> fields) {
    final newFields = Set<Field>.from(fields);

    if (_fields != null) newFields.addAll(_fields);

    return LoggerContext(_logger, newFields);
  }
}
