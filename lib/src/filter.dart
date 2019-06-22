import 'package:structlog/src/record.dart';

/// [Filter] used to filter [Record]s by criteria defined in [Filter.filter].
abstract class Filter {
  /// Tests whether specified [record] will be processed.
  ///
  /// If `false` is returned records is not permitted to be processed,
  /// otherwise is permitted.
  bool filter(Record record);
}
