import 'package:jetlog/src/field.dart';
import 'package:jetlog/src/interface.dart';
import 'package:jetlog/src/level.dart';
import 'package:jetlog/src/logger_impl.dart';
import 'package:jetlog/src/record_impl.dart';
import 'package:jetlog/src/timer.dart';
import 'package:jetlog/src/timer_impl.dart';

class LoggingContext implements Interface {
  LoggingContext(this._logger, [this._fields = const {}]);

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
  Interface bind([Iterable<Field>? fields]) => LoggingContext(_logger, {
        ...?fields,
        ..._fields,
      });

  @override
  Timer startTimer(String message, {Level level = Level.debug}) =>
      TimerImpl(this, level)..start(message);
}
