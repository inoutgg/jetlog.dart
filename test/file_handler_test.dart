import 'dart:async';
import 'dart:io' show Platform;

import 'package:file/memory.dart';
import 'package:path/path.dart' as path;
import 'package:strlog/formatters.dart';
import 'package:strlog/src/handlers/file_handler/io.dart';
import 'package:strlog/src/record_impl.dart';
import 'package:strlog/src/handlers/file_handler/policy.dart';
import 'package:strlog/strlog.dart';
import 'package:test/test.dart';

void main() {
  group('FileHandler', () {
    late MemoryFileSystem fs;
    late String logPath;
    late Formatter formatter;

    setUp(() {
      fs = MemoryFileSystem(
          style: Platform.isWindows
              ? FileSystemStyle.windows
              : FileSystemStyle.posix);
      logPath = path.join('logs', 'test.log');
      formatter = (record) => '${record.message}\n'.codeUnits;
    });

    String normalizePath(String p) => path.normalize(p);

    bool pathEquals(String path1, String path2) {
      return normalizePath(path1) == normalizePath(path2);
    }

    test('creates log file and directory if they do not exist', () {
      final handler = FileHandler(
        const LogFileRotationPolicy.never(),
        formatter: formatter,
        path: logPath,
        fs: fs,
      );

      expect(fs.file(logPath).existsSync(), isTrue);
      handler.close();
    });

    test('writes records to file', () async {
      final handler = FileHandler(
        const LogFileRotationPolicy.never(),
        formatter: formatter,
        path: logPath,
        fs: fs,
      );

      final record = RecordImpl(
        level: Level.info,
        message: 'test message',
        timestamp: DateTime.now(),
      );

      handler.handle(record);
      await handler.close();

      final content = fs.file(logPath).readAsStringSync();
      expect(content, contains('test message'));
    });

    test('respects filter', () async {
      final handler = FileHandler(
        const LogFileRotationPolicy.never(),
        formatter: formatter,
        path: logPath,
        fs: fs,
      );

      handler.filter = (record) => record.level >= Level.error;

      final infoRecord = RecordImpl(
        level: Level.info,
        message: 'info message',
        timestamp: DateTime.now(),
      );

      final errorRecord = RecordImpl(
        level: Level.error,
        message: 'error message',
        timestamp: DateTime.now(),
      );

      handler.handle(infoRecord);
      handler.handle(errorRecord);
      await handler.close();

      final content = fs.file(logPath).readAsStringSync();
      expect(content, isNot(contains('info message')));
      expect(content, contains('error message'));
    });

    test('rotates file based on size policy', () async {
      final maxSize = 20; // Small size to trigger rotation easily
      final handler = FileHandler(
        LogFileRotationPolicy.sized(maxSize),
        formatter: formatter,
        path: logPath,
        fs: fs,
      );

      final longMessage = 'a' * maxSize;
      final record = RecordImpl(
        level: Level.info,
        message: longMessage,
        timestamp: DateTime.now(),
      );

      // Write enough to trigger rotation
      handler.handle(record);
      handler.handle(record);
      await handler.close();

      // Check that we have more than one log file
      final directory = fs.directory(path.dirname(logPath));
      final files = directory.listSync().where((f) => f.path.endsWith('.log'));
      expect(files.length, greaterThan(1));
    });

    test('rotates file based on time policy', () async {
      final handler = FileHandler(
        LogFileRotationPolicy.periodic(Duration(milliseconds: 100)),
        formatter: formatter,
        path: logPath,
        fs: fs,
      );

      final record = RecordImpl(
        level: Level.info,
        message: 'test message',
        timestamp: DateTime.now(),
      );

      handler.handle(record);
      await Future<void>.delayed(Duration(milliseconds: 150));
      handler.handle(record);
      await handler.close();

      final directory = fs.directory(path.dirname(logPath));
      final files = directory.listSync().where((f) => f.path.endsWith('.log'));
      expect(files.length, greaterThan(1));
    });

    test('respects max backups count', () async {
      final maxBackups = 2;
      final handler = FileHandler(
        LogFileRotationPolicy.sized(10),
        formatter: formatter,
        path: logPath,
        fs: fs,
        maxBackupsCount: maxBackups,
      );

      final record = RecordImpl(
        level: Level.info,
        message: 'a' * 20, // Ensure rotation
        timestamp: DateTime.now(),
      );

      // Create multiple rotations
      for (var i = 0; i < maxBackups + 2; i++) {
        handler.handle(record);
        // give time to elapse for a unique file name
        await Future<void>.delayed(Duration(seconds: 1));
      }

      await handler.close();

      final directory = fs.directory(path.dirname(logPath));
      final files = directory.listSync().where((f) => f.path.endsWith('.log'));
      // Current file + max backups
      expect(files.length, equals(maxBackups + 1));
    });

    test(
        'removes oldest files when max count is exceeded and maintains chronological order',
        () async {
      final maxBackups = 2;
      final handler = FileHandler(
        LogFileRotationPolicy.sized(10),
        formatter: formatter,
        path: logPath,
        fs: fs,
        maxBackupsCount: maxBackups,
      );

      final record = RecordImpl(
        level: Level.info,
        message: 'a' * 20, // Ensure rotation
        timestamp: DateTime.now(),
      );

      // Create multiple rotations with timestamps
      final createdFiles = <String>[];

      for (var i = 0; i < maxBackups + 2; i++) {
        handler.handle(record);
        await Future<void>.delayed(Duration(seconds: 1));

        final directory = fs.directory(path.dirname(logPath));
        final files = directory
            .listSync()
            .where((f) => f.path.endsWith('.log'))
            .map((f) => normalizePath(f.path))
            .toList();

        // Store newly created backup file
        for (final file in files) {
          if (!createdFiles.contains(file)) {
            createdFiles.add(file);
          }
        }
      }

      await handler.close();

      final directory = fs.directory(path.dirname(logPath));
      final remainingFiles = directory
          .listSync()
          .where((f) => f.path.endsWith('.log'))
          .map((f) => normalizePath(f.path))
          .toList();

      // Extract timestamps from filenames to verify chronological order
      List<String> extractTimestamps(List<String> files) {
        return files
            .where((f) => !pathEquals(f, logPath))
            .map((f) {
              final match = RegExp(r'_(\d{14})\.log$').firstMatch(f);
              return match?.group(1) ?? '';
            })
            .where((t) => t.isNotEmpty)
            .toList();
      }

      final timestamps = extractTimestamps(remainingFiles);
      final sortedTimestamps = [...timestamps]..sort();

      // Verify total number of files (current + backups)
      expect(remainingFiles.length, equals(maxBackups + 1));

      // Verify timestamps are in ascending order (older to newer)
      expect(timestamps, equals(sortedTimestamps),
          reason: 'Backup files should be sorted from old to new');

      // Verify the oldest files were removed
      final allTimestamps = extractTimestamps(createdFiles);
      final removedTimestamps =
          allTimestamps.take(allTimestamps.length - maxBackups);

      for (final timestamp in removedTimestamps) {
        expect(timestamps.contains(timestamp), isFalse,
            reason: 'Older timestamp $timestamp should have been removed');
      }

      // Verify the newest files were kept
      final keptTimestamps =
          allTimestamps.skip(allTimestamps.length - maxBackups);
      for (final timestamp in keptTimestamps) {
        expect(timestamps.contains(timestamp), isTrue,
            reason: 'Newer timestamp $timestamp should have been kept');
      }
    });
  });
}
