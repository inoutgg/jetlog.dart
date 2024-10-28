import 'dart:async' show FutureOr;

import 'package:jetlog/formatters.dart' show Formatter;
import 'package:jetlog/jetlog.dart' show Handler, Record;

/// Minimum allowed value of `maxSize` for [RotationPolicy.sized].
const int minSize = 1024; // 1kb

/// Minimum allowed value of `interval` for [RotationPolicy.interval].
const Duration minInterval = Duration(seconds: 1);

/// Logging file current stats.
abstract class Stat {
  /// Logging file size.
  int get size;

  /// Time logging file was last modified at.
  DateTime get modified;
}

/// Rotation policy is used to set [FileHandler] rotation mechanism.
///
/// By default 3 predefined policies are available [RotationPolicy.never],
/// [RotationPolicy.interval] and [RotationPolicy.size] setting
/// never, interval-based and size-based mechanisms correspondingly.
abstract class RotationPolicy {
  /// Creates a new rotation policy to never rotate logging file.
  const factory RotationPolicy.never() = _NeverRotationPolicy;

  /// Creates a new rotation policy to rotate logging file based
  /// on [interval] duration. Once [interval] time is exceeded
  /// the logging file must be rotated.
  const factory RotationPolicy.interval(Duration interval) =
      _IntervalRotationPolicy;

  /// Creates a new rotation policy to rotate logging file based
  /// on its size. Once size is equal or bigger than [maxSize]
  /// the logging file must be rotated.
  const factory RotationPolicy.sized(int maxSize) = _SizedRotationPolicy;

  /// Determines whether logging file should be rotated.
  bool shouldRotation(Stat stat);
}

class _NeverRotationPolicy implements RotationPolicy {
  const _NeverRotationPolicy();

  @override
  bool shouldRotation(Stat stat) {
    throw UnimplementedError('Unimplemented!');
  }
}

class _SizedRotationPolicy implements RotationPolicy {
  const _SizedRotationPolicy(
    this.maxSize,
  ) : assert(maxSize >= minSize);

  final int maxSize;

  @override
  bool shouldRotation(Stat stat) {
    throw UnimplementedError('Unimplemented!');
  }
}

class _IntervalRotationPolicy implements RotationPolicy {
  const _IntervalRotationPolicy(this.interval)
      : assert(interval >= minInterval);

  final Duration interval;

  @override
  bool shouldRotation(Stat stat) {
    throw UnimplementedError('Unimplemented!');
  }
}

/// Rotator is capable to rotate [src] to [dest] file.
typedef Rotator = FutureOr<void> Function(String src, String dest);

/// File rotator that is simply renames [src] to [dest] and fallback
/// to hard copying on fail.
FutureOr<void> rotator(String src, String dest) async {
  throw UnimplementedError('Unimplemented!');
}

/// [FileHandler] is used to write logging records to specified file.
///
/// **Caution**: [FileHandler] is only supported targeting
/// Dart VM (including Flutter) and will fail on other platforms.
///
/// An optional rotation policy can be provided to set file rotation condition.
/// If no [rotationPolicy] is provided it defaults to [RotationPolicy.never]
/// which means the logging file won't be rotated.
///
/// An optional rotator can be provided to set file rotation mechanism.
/// By default [rotator] mechanism is set.
///
/// On rotating file is gotten a logfile index suffix.
class FileHandler extends Handler {
  /// Creates a new [FileHandler] targeting file under given URI.
  ///
  /// An optional [rotationPolicy] can be provided to set rotation conditions.
  /// There available different kinds of rotation policy auto of the box
  /// such as time, size rotation policy, etc. It is also possible to define
  /// custom policy to control rotation.
  ///
  /// If [maxBackUps] is non-zero, at most [maxBackUps] backup files will be
  /// kept.
  FileHandler(Uri uri,
      {required Formatter formatter,
      RotationPolicy rotationPolicy = const RotationPolicy.never(),
      Rotator rotator = rotator,
      int maxBackUps = 0});

  /// Sets records filterer.
  ///
  /// Set filterer behaves the same way as a [Logger] filter.
  set filter(Filter filter) {
    throw UnimplementedError('Unimplemented!');
  }

  /// Rotates logging file.
  FutureOr<void> rotate() {
    throw UnimplementedError('Unimplemented!');
  }

  @override
  void handle(Record record) {
    throw UnimplementedError('Unimplemented!');
  }
}
