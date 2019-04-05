import 'package:structlog/src/interface.dart';
import 'package:structlog/src/record.dart';

/// Severity level of the record. It controls output of particular logger.
///
/// There are 5 predefined levels: [Level.debug], [Level.trace], [Level.info],
/// [Level.warning], [Level.error] and [Level.fatal] (sorted in descendant order
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
/// unique [value] is between `0x0` ([Level.all]) and `0xffff` ([Level.off]).
/// Also consider that values: `0x1`, `0x2`, `0x3`, `0x4`, `0x5` and [0x6] are
/// reserved.
class Level implements Comparable<Level> {
  const Level({this.name, this.value});

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
  String toString() => '<Level name=$name>';

  /// Special level value to allow records with any severity level to be emitted
  /// by logger.
  ///
  /// It is an error to provide this value to [Record.level].
  static const Level all = Level(name: '<ALL>', value: 0x0);

  /// A severity level for debugging records.
  static const Level debug = Level(name: 'DEBUG', value: 0x1);

  /// A severity level for tracing records; used by [Interface.trace] and
  /// [Tracer.stop].
  static const Level trace = Level(name: 'TRACE', value: 0x2);

  /// A severity level for informative records.
  static const Level info = Level(name: 'INFO', value: 0x3);

  /// A severity level for warning records.
  static const Level warning = Level(name: 'WARNING', value: 0x4);

  /// A severity level for danger records.
  static const Level danger = Level(name: 'DANGER', value: 0x5);

  /// A severity level for fatal records; often after records with fatal
  /// severity level follows application process end.
  static const Level fatal = Level(name: 'FATAL', value: 0x6);

  /// Special level value to disable logger output.
  ///
  /// It is an error to provide this value to [Record.level].
  static const Level off = Level(name: '<OFF>', value: 0xffff);
}
