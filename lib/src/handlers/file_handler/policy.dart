abstract class FileRotationPolicy {
  // [FileRotationPolicy.never] creates a never rotating policy.
  //
  // [FileHandler] with the policy will never rotate a file, effectively
  // writting the data to the same file until the end of the application
  // lifetime.
  const factory FileRotationPolicy.never() = _NeverFileRotationPolicy;

  // [FileRotationPolicy.interval] creates a interval based rotation policy.
  //
  // [FileHandler] with the policy will rotate a logging file each [duration].
  const factory FileRotationPolicy.interval(Duration duration) =
      _IntervalFileRotationPolicy;

  bool shouldRotate();
}

// [_NeverFileRotationPolicy] never rotates file.
class _NeverFileRotationPolicy implements FileRotationPolicy {
  const _NeverFileRotationPolicy();

  @override
  bool shouldRotate() => false;
}

// [_intervalFileRotationPolicy] rotates a file each [duration].
class _IntervalFileRotationPolicy implements FileRotationPolicy {
  const _IntervalFileRotationPolicy(this.duration);

  final Duration duration;

  @override
  bool shouldRotate() {
    final now = DateTime.now();
    final diff = now.difference(DateTime.now());

    return diff.inMilliseconds < duration.inMilliseconds;
  }
}
