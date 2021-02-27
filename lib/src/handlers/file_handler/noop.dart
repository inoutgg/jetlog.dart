import 'dart:async' show FutureOr;

import 'package:jetlog/formatters.dart' show Formatter;
import 'package:jetlog/jetlog.dart' show Handler, Record;

/// Minimum allowed value of maxSize for [RotationPolicy.sized].
const int minSize = 1024; // 1kb

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
  const factory RotationPolicy.never() = _NeverRotatePolicy;

  /// Creates a new rotation policy to rotate logging file based
  /// on [interval] duration. Once [interval] time is exceeded
  /// the logging file must be rotated.
  const factory RotationPolicy.interval(Duration interval) =
      _IntervalRotatePolicy;

  /// Creates a new rotation policy to rotate logging file based
  /// on its size. Once size is equal or bigger than [maxSize]
  /// the logging file must be rotated.
  const factory RotationPolicy.sized({required int maxSize}) = _SizedRotatePolicy;

  /// Determines whether logging file should be rotated.
  bool shouldRotate(Stat stat);
}

class _NeverRotatePolicy implements RotationPolicy {
  const _NeverRotatePolicy();

  @override
  bool shouldRotate(Stat stat) {
    throw UnimplementedError('Unimplemented!');
  }
}

class _SizedRotatePolicy implements RotationPolicy {
  const _SizedRotatePolicy({
    required this.maxSize,
  }) : assert(maxSize >= minSize);

  final int maxSize;

  @override
  bool shouldRotate(Stat stat) {
    throw UnimplementedError('Unimplemented!');
  }
}

class _IntervalRotatePolicy implements RotationPolicy {
  const _IntervalRotatePolicy(this.interval);

  final Duration interval;

  @override
  bool shouldRotate(Stat stat) {
    throw UnimplementedError('Unimplemented!');
  }
}

/// [FileHandler] is used to write logging records to specified file.
///
/// **Caution**: [FileHandler] is only supported targeting
/// Dart VM (including Flutter) and will fail on other platforms.
///
/// An optional rotation policy can be set to set file rotation condition.
/// If no [rotationPolicy] is provided it defaults to [RotationPolicy.never]
/// which means the logging file won't be rotated.
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
  ///
  /// If [compress] is set, backup file will be compressed using gzip.
  /// By default compression is off.
  FileHandler(Uri uri,
      {required Formatter formatter,
      RotationPolicy rotationPolicy = const RotationPolicy.never(),
      bool compress = false,
      int maxBackUps = 0});

  /// Returns current logging file stats.
  Stat get stat => throw UnimplementedError('Unimplemented!');

  /// Rotates logging file.
  FutureOr<void> rotate() {
    throw UnimplementedError('Unimplemented!');
  }

  @override
  void handle(Record record) {
    throw UnimplementedError('Unimplemented!');
  }
}
