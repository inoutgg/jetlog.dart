/// [LogFileStat] represents statistics about a log file, including its size and modification time.
abstract class LogFileStat {
  /// Time of the first modification of the log file.
  DateTime get firstChanged;

  /// The current size of the log file in bytes.
  int get size;
}

/// [LogFileRotationPolicy] determines under what conditions the [FileHandler] should stop writing to
/// the current log file and start writing to a new one.
abstract class LogFileRotationPolicy {
  /// [LogFileRotationPolicy.never] creates a never rotating policy.
  ///
  /// [FileHandler] with the policy will never rotate a file, effectively
  /// writting the data to the same file until the end of the application
  /// lifetime.
  const factory LogFileRotationPolicy.never() = _NeverLogFileRotationPolicy;

  /// [LogFileRotationPolicy.periodic] creates a period based rotation policy.
  ///
  /// [FileHandler] with the policy will rotate a logging file each [period].
  const factory LogFileRotationPolicy.periodic(Duration period) =
      _PeriodicLogFileRotationPolicy;

  /// [LogFileRotationPolicy.sized] creates a size based rotation policy.
  ///
  /// [FileHandler] with the policy will rotate a logging file when its size
  /// exceeds [maxSizeInBytes].
  const factory LogFileRotationPolicy.sized(int maxSizeInBytes) =
      _SizedLogFileRotationPolicy;

  /// [LogFileRotationPolicy.union] combines multiple rotation policies into one.
  /// File rotation occurs when any of the provided policies triggers.
  const factory LogFileRotationPolicy.union(
      Iterable<LogFileRotationPolicy> policies) = _UnionLogFileRotationPolicy;

  /// Determines whether log files should be rotated based on the provided [stat].
  /// Returns `true` if file rotation should occur, `false` otherwise.
  bool shouldRotate(LogFileStat stat);
}

// [_NeverLogFileRotationPolicy] never rotates file.
class _NeverLogFileRotationPolicy implements LogFileRotationPolicy {
  const _NeverLogFileRotationPolicy();

  @override
  bool shouldRotate(_) => false;
}

// [_PeriodicLogFileRotationPolicy] rotates file each [period].
class _PeriodicLogFileRotationPolicy implements LogFileRotationPolicy {
  const _PeriodicLogFileRotationPolicy(this.period);

  final Duration period;

  @override
  bool shouldRotate(LogFileStat stat) {
    final now = DateTime.now();
    final diff = now.difference(stat.firstChanged);

    return period < diff;
  }
}

/// [_SizedLogFileRotationPolicy] rotates file when size exceeds [_maxSizeInBytes].
class _SizedLogFileRotationPolicy implements LogFileRotationPolicy {
  const _SizedLogFileRotationPolicy(this._maxSizeInBytes);

  final int _maxSizeInBytes;

  @override
  bool shouldRotate(LogFileStat stat) {
    return _maxSizeInBytes <= stat.size;
  }
}

/// [_UnionLogFileRotationPolicy] combines multiple rotation policies into one.
class _UnionLogFileRotationPolicy implements LogFileRotationPolicy {
  const _UnionLogFileRotationPolicy(this._policies);

  final Iterable<LogFileRotationPolicy> _policies;

  @override
  bool shouldRotate(LogFileStat stat) {
    for (final p in _policies) {
      if (p.shouldRotate(stat)) {
        return true;
      }
    }

    return false;
  }
}
