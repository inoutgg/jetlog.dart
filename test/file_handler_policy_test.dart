import 'package:strlog/src/handlers/file_handler/policy.dart';
import 'package:test/test.dart';

class TestLogFileStat implements LogFileStat {
  TestLogFileStat({
    required this.firstChanged,
    required this.size,
  });

  @override
  final DateTime firstChanged;

  @override
  final int size;
}

void main() {
  group('LogFileRotationPolicy', () {
    group('never', () {
      test('should never rotate', () {
        final policy = LogFileRotationPolicy.never();
        final stat = TestLogFileStat(
          firstChanged: DateTime.now(),
          size: 1000000,
        );

        expect(policy.shouldRotate(stat), isFalse);
      });
    });

    group('periodic', () {
      test('should not rotate if period has not elapsed', () {
        final now = DateTime.now();
        final policy = LogFileRotationPolicy.periodic(Duration(hours: 1));
        final stat = TestLogFileStat(
          firstChanged: now,
          size: 100,
        );

        expect(policy.shouldRotate(stat), isFalse);
      });

      test('should rotate if period has elapsed', () {
        final oneHourAgo = DateTime.now().subtract(Duration(hours: 2));
        final policy = LogFileRotationPolicy.periodic(Duration(hours: 1));
        final stat = TestLogFileStat(
          firstChanged: oneHourAgo,
          size: 100,
        );

        expect(policy.shouldRotate(stat), isTrue);
      });
    });

    group('sized', () {
      test('should not rotate if size is below limit', () {
        final policy = LogFileRotationPolicy.sized(1000);
        final stat = TestLogFileStat(
          firstChanged: DateTime.now(),
          size: 500,
        );

        expect(policy.shouldRotate(stat), isFalse);
      });

      test('should rotate if size equals limit', () {
        final policy = LogFileRotationPolicy.sized(1000);
        final stat = TestLogFileStat(
          firstChanged: DateTime.now(),
          size: 1000,
        );

        expect(policy.shouldRotate(stat), isTrue);
      });

      test('should rotate if size exceeds limit', () {
        final policy = LogFileRotationPolicy.sized(1000);
        final stat = TestLogFileStat(
          firstChanged: DateTime.now(),
          size: 1500,
        );

        expect(policy.shouldRotate(stat), isTrue);
      });
    });

    group('union', () {
      test('should not rotate if no policy triggers', () {
        final policy = LogFileRotationPolicy.union([
          LogFileRotationPolicy.sized(1000),
          LogFileRotationPolicy.periodic(Duration(hours: 1)),
        ]);
        final stat = TestLogFileStat(
          firstChanged: DateTime.now(),
          size: 500,
        );

        expect(policy.shouldRotate(stat), isFalse);
      });

      test('should rotate if any policy triggers - size', () {
        final policy = LogFileRotationPolicy.union([
          LogFileRotationPolicy.sized(1000),
          LogFileRotationPolicy.periodic(Duration(hours: 1)),
        ]);
        final stat = TestLogFileStat(
          firstChanged: DateTime.now(),
          size: 1500,
        );

        expect(policy.shouldRotate(stat), isTrue);
      });

      test('should rotate if any policy triggers - time', () {
        final policy = LogFileRotationPolicy.union([
          LogFileRotationPolicy.sized(1000),
          LogFileRotationPolicy.periodic(Duration(hours: 1)),
        ]);
        final stat = TestLogFileStat(
          firstChanged: DateTime.now().subtract(Duration(hours: 2)),
          size: 500,
        );

        expect(policy.shouldRotate(stat), isTrue);
      });

      test('empty union should never rotate', () {
        final policy = LogFileRotationPolicy.union([]);
        final stat = TestLogFileStat(
          firstChanged: DateTime.now(),
          size: 1500,
        );

        expect(policy.shouldRotate(stat), isFalse);
      });
    });
  });
}
