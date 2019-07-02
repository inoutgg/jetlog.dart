import 'package:jetlog/jetlog.dart' show Filter, Record;

/// [MultiFilter] composites multiple filters, each of enclosing filters
/// receives incoming record. Record is discarded once one of the filters
/// filter it out.
class MultiFilter {
  MultiFilter(this._filters);

  final Iterable<Filter> _filters;

  bool call(Record record) {
    if (_filters.isNotEmpty) {
      for (final f in _filters) {
        if (!f.call(record)) {
          return false;
        }
      }
    }

    return true;
  }
}
