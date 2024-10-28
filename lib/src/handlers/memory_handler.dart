import 'package:strlog/strlog.dart' show Handler, Record;

/// [MemoryHandler] is used to keep records in memory; it keeps sequence
/// of records in the emitting order.
class MemoryHandler extends Handler {
  MemoryHandler() : _records = [];

  final List<Record> _records;

  /// All records processed by this handler.
  Iterable<Record> get records => List.unmodifiable(_records);

  @override
  void handle(Record record) => _records.add(record);
}
