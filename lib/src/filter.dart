import 'package:jetlog/src/record.dart';

/// [Filter] used to filter [Record]s by criteria.
///
/// If `false` is returned records is not permitted to be processed,
/// otherwise is permitted.
typedef Filter = bool Function(Record);
