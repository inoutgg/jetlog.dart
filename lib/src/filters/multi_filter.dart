import 'package:strlog/strlog.dart' show Filter, Record;

/// [MultiFilter] composites multiple filters, each of enclosing filters
/// receives incoming record. Record is discarded once one of the filters
/// filter it out.
///
/// Example:
/// ```dart
/// final filters = {filterOne, filterTwo, filterThree};
/// final logger = Logger.getLogger('example.multi_filter')
///   ..filter = MultiFilter(filters);
/// ```
class MultiFilter {
  MultiFilter(this._filters);

  final Iterable<Filter> _filters;

  bool call(Record record) {
    if (_filters.isNotEmpty) {
      for (final f in _filters) {
        if (!f(record)) {
          return false;
        }
      }
    }

    return true;
  }
}
