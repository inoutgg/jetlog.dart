import 'package:jetlog/src/field.dart';
import 'package:jetlog/src/interface.dart';
import 'package:jetlog/src/logger_impl.dart';
import 'package:jetlog/src/record_impl.dart';
import 'package:jetlog/src/tracer.dart';
import 'package:jetlog/src/level.dart';
import 'package:jetlog/src/tracer_impl.dart';

class LoggingContext implements Interface {
  LoggingContext(this._logger, [this._fields]);

  final LoggerImpl _logger;
  final Set<Field> _fields;

  @override
  void log(Level level, String message) {
    if (_logger.isEnabledFor(level)) {
      final record = RecordImpl(
          name: _logger.name,
          timestamp: DateTime.now(),
          level: level,
          message: message,
          fields: _fields);

      _logger.add(record);
    }
  }

  @override
  void debug(String message) => log(Level.debug, message);

  @override
  Tracer trace(String message, [Level level = Level.debug]) =>
      TracerImpl(this, level)..start(message);

  @override
  void info(String message) => log(Level.info, message);

  @override
  void warning(String message) => log(Level.warning, message);

  @override
  void danger(String message) => log(Level.danger, message);

  @override
  void fatal(String message) => log(Level.fatal, message);

  @override
  Interface bind([Iterable<Field> fields]) => LoggingContext(_logger, {
        if (fields != null) ...fields,
        if (_fields != null) ..._fields,
      });
}
