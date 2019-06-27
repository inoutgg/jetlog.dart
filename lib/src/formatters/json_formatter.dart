import 'dart:convert' show JsonEncoder, Utf8Encoder;

import 'package:meta/meta.dart' show required;
import 'package:structlog/structlog.dart'
    show Field, FieldKind, Level, Obj, Record;

import 'package:structlog/src/formatters/formatter.dart';

/// [JsonFormatter] is used to encode [Record] to JSON format.
///
/// Known pitfall is that this formatter de-duplicates and overrides
/// collapsing fields. Using the same key multiple time results only to
/// single field is included to the final output. As such we strongly recommend
/// not to put fields in to any collections fields with key such as `level`,
/// `message`, `name` and `timestamp`.
///
/// Use [JsonFormatter.createFormatter] to receive pre-configured
/// [JsonFormatter].
class JsonFormatter<L, T> implements Formatter {
  /// Creates a new [JsonFormatter].
  ///
  /// [formatLevel], [formatTimestamp] callbacks must be provided to format
  /// severity levels and timestamp respectively.
  ///
  /// Optional [formatFields] callbacks may be provided used to
  /// format collection fields.
  ///
  /// Optional [indent] value may be also provided, which denotes size of
  /// common indentation (per level indentation) each blocks is prepended with.
  JsonFormatter(
      {@required this.formatLevel,
      @required this.formatTimestamp,
      this.formatFields = _formatFields,
      int indent})
      : _utf8 = const Utf8Encoder(),
        _json = indent != null
            ? JsonEncoder.withIndent(' ' * indent)
            : const JsonEncoder();

  final Utf8Encoder _utf8;
  final JsonEncoder _json;

  final LevelFormatCallback<L> formatLevel;
  final TimestampFormatCallback<T> formatTimestamp;
  final FieldsFormatCallback<Map<String, dynamic>> formatFields;

  /// Returns a new [TextFormatter] with set both [formatLevel] and
  /// [formatTimestamp].
  static JsonFormatter<Map<String, dynamic /* String | int */ >, String>
      createFormatter({int indent}) => JsonFormatter(
          formatLevel: _formatLevel,
          formatTimestamp: _formatTimestamp,
          indent: indent);

  @override
  List<int> call(Record record) {
    final fields = formatFields(record.fields);
    final dict = <String, dynamic>{
      'level': formatLevel(record.level),
      'message': record.message,
      'name': record.name,
      'timestamp': formatTimestamp(record.timestamp),
      if (fields != null && fields.isNotEmpty) ...fields,
    };

    return _utf8.convert(_json.convert(dict));
  }
}

Map<String, dynamic /* String | int */ > _formatLevel(Level level) =>
    <String, dynamic>{'name': level.name, 'severity': level.value};

String _formatTimestamp(DateTime timestamp) => timestamp.toString();

Map<String, dynamic> _formatFields(Iterable<Field> fields) {
  final dict = <String, dynamic>{};

  if (fields != null) {
    for (final field in fields) {
      switch (field.kind) {
        case FieldKind.object:
          dict[field.name] = _formatFields((field as Obj).value);
          break;

        default:
          dict[field.name] = field.value.toString();
          break;
      }
    }
  }

  return dict;
}
