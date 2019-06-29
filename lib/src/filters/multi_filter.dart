import 'package:jetlog/jetlog.dart' show Filter, Record;

/// [MultiFilter] composites multiple filters, each of enclosing filters
/// receives incoming record. Record is discarded once one of the filters
/// filter it out.
class MultiFilter implements Filter {
  MultiFilter(this._filters);

  final Iterable<Filter> _filters;

  @override
  bool filter(Record record) {
    if (_filters.isNotEmpty) {
      for (final f in _filters) {
        if (!f.filter(record)) {
          return false;
        }
      }
    }

    return true;
  }
}
