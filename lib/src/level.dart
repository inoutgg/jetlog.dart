import 'package:jetlog/src/logger.dart';
import 'package:jetlog/src/record.dart';

/// Severity level of the record used to controls output of particular logger.
///
/// There are 5 predefined levels: [Level.fatal], [Level.danger],
/// [Level.warning], [Level.info] and [Level.debug] (sorted in ascending order
/// by their values).
///
/// To prevent logger from emitting any records set [Logger.level] to
/// [Level.off].
///
/// To emit records with any severity level by logger set [Logger.level] to
/// [Level.all].
///
/// User-defined severity levels are also supported. Use [Level] constructor
/// to define a new severity level. Make sure that defined level's
/// unique [value] is between `0x0` ([Level.all]) and `0xffff` ([Level.off]);
/// and does not overlap with `0x100`, `0x200`, `0x300`, `0x400`, `0x500` and
/// `0x600` reserved for [debug], [info], [warning], [danger] and [fatal]
/// levels respectively.
class Level implements Comparable<Level> {
  const Level({required this.name, required this.value});

  /// User-readable name of this severity level.
  final String name;

  /// Unique value for this severity level.
  final int value;

  @override
  int get hashCode => value;

  @override
  bool operator ==(Object other) => other is Level && value == other.value;

  bool operator >(Level otherLevel) => value > otherLevel.value;

  bool operator <(Level otherLevel) => value < otherLevel.value;

  bool operator >=(Level otherLevel) => value >= otherLevel.value;

  bool operator <=(Level otherLevel) => value <= otherLevel.value;

  @override
  int compareTo(Level otherLevel) => value - otherLevel.value;

  @override
  String toString() => 'Level(name=$name)';

  /// Special level value used to allow records with any severity level
  /// to be emitted by logger.
  ///
  /// It is an error to provide this value to [Record.level].
  static const Level all = Level(name: '<ALL>', value: 0x0);

  /// A severity level for *debugging* records; often records with debug level
  /// used to provide diagnostic information useful in development, testing,
  /// etc., such records are usually discarded in production.
  static const Level debug = Level(name: 'DEBUG', value: 0x100);

  /// A severity level for *informative* records; often records with info level
  /// used to provide general purpose information such as start/stop of service,
  /// etc.
  static const Level info = Level(name: 'INFO', value: 0x200);

  /// A severity level for *warning* records; often records with the warning
  /// level used to notify about events that may potentially cause application
  /// oddities.
  static const Level warning = Level(name: 'WARNING', value: 0x300);

  /// A severity level for *danger* records; often records with the error level
  /// used to notify about fatal error in the operation without impact
  /// on the stability of a service or an application.
  static const Level danger = Level(name: 'DANGER', value: 0x400);

  /// A severity level for *fatal* records; often after records with fatal
  /// severity level follows application process end e.g. `exit(1)`.
  static const Level fatal = Level(name: 'FATAL', value: 0x500);

  /// Special level value to disable logger output.
  ///
  /// It is an error to provide this value to [Record.level].
  static const Level off = Level(name: '<OFF>', value: 0xffff);
}
