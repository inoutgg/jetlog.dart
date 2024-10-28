import 'package:strlog/src/field.dart';
import 'package:strlog/src/interface.dart';
import 'package:strlog/src/level.dart';
import 'package:strlog/src/logger_impl.dart';
import 'package:strlog/src/record_impl.dart';
import 'package:strlog/src/timer.dart';
import 'package:strlog/src/timer_impl.dart';

class LoggingContext implements Interface {
  LoggingContext(this._logger, [this._fields = const {}]);

  final LoggerImpl _logger;
  final Set<Field> _fields;

  @override
  void log(Level level, String message, [Iterable<Field>? fields]) {
    if (_logger.isEnabledFor(level)) {
      late final Set<Field> recordFields;
      if (fields == null) {
        recordFields = _fields;
      } else {
        recordFields = {...fields, ..._fields};
      }

      final record = RecordImpl(
          name: _logger.name,
          timestamp: DateTime.now(),
          level: level,
          message: message,
          fields: recordFields);

      _logger.add(record);
    }
  }

  @override
  @pragma('vm:prefer-inline')
  Interface withFields(Iterable<Field> fields) => LoggingContext(_logger, {
        ...fields,
        ..._fields,
      });

  @override
  Timer startTimer(String message, {Level level = Level.debug}) =>
      TimerImpl(this, level)..start(message);
}
