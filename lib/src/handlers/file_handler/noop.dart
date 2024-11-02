import 'package:file/file.dart' show FileSystem;
import 'package:strlog/formatters.dart' show Formatter;
import 'package:strlog/strlog.dart' show Handler, Record;

import './policy.dart';

class FileHandler extends Handler {
  FileHandler(LogFileRotationPolicy policy,
      {required String path,
      required int maxBackupsCount,
      required Formatter formatter,
      FileSystem? fs});

  @override
  void handle(Record record) {
    throw UnsupportedError('unsupported platform');
  }
}
