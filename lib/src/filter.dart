import 'package:structlog/src/handler.dart';
import 'package:structlog/src/logger.dart';
import 'package:structlog/src/record.dart';

/// An error thrown when the same instance of [Filter] is registered twice a
/// time for the same [Filterer].
class FilterRegisterError extends Error {
  FilterRegisterError(this.message);

  /// This error message.
  final String message;
}

/// [Filter] allows [Logger]s and [Handler]s to filter [Record]s by
/// criterias defined in [Filter.filter].
abstract class Filter {
  /// Tests whether specified [record] will be processed. If `false` is returned
  /// records is not permitted to be processed, otherwise is permitted.
  bool filter(Record record);
}

/// Filterer is capable to filter [Record]s.
abstract class Filterer {
  final Set<Filter> _filters = Set();

  /// Adds a [filter] to the filter list.
  void addFilter(Filter filter) {
    if (_filters.contains(filter)) {
      throw FilterRegisterError('Filter is already added!');
    }

    _filters.add(filter);
  }

  /// Removes a [filter] from the filter list.
  void removeFilter(Filter filter) => _filters.remove(filter);

  /// Passing [record] over this filterer's filters and calculate whether
  /// it will be processed.
  ///
  /// The [Filterer.filter] will immediately return `false` if one of
  /// the filters return `false`; if none of the filters returns `false`
  /// it returns `true`.
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
