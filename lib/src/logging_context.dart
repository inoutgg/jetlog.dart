import 'package:jetlog/src/field.dart';
import 'package:jetlog/src/interface.dart';
import 'package:jetlog/src/level.dart';
import 'package:jetlog/src/logger_impl.dart';
import 'package:jetlog/src/record_impl.dart';

class LoggingContext extends Interface {
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
  @pragma('vm:prefer-inline')
  Interface bind([Iterable<Field> fields]) => LoggingContext(_logger, {
        if (fields != null) ...fields,
        if (_fields != null) ..._fields,
      });
}
