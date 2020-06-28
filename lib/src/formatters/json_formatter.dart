import 'dart:convert' show JsonEncoder, Utf8Encoder;

import 'package:jetlog/jetlog.dart' show Field, FieldKind, Level, Obj, Record;
import 'package:jetlog/src/formatters/formatter.dart';

@pragma('vm:prefer-inline')
Map<String, Object> _formatLevel(Level level) =>
    <String, Object>{'name': level.name, 'severity': level.value};

@pragma('vm:prefer-inline')
String _formatTimestamp(DateTime timestamp) => timestamp.toString();

/// [JsonFormatter] is used to encode [Record] to JSON format.
///
/// Known pitfall is that this formatter de-duplicates and overrides
/// collapsing fields. Using the same key multiple time results only to
/// single field is included to the final output. As such we strongly recommend
/// not to put fields in to any collections fields with key such as `level`,
/// `message`, `name` and `timestamp`.
class JsonFormatter with FormatterBase<MapEntry<String, Object>> {
  JsonFormatter._(this._json, this.formatLevel, this.formatTimestamp)
      : _utf8 = const Utf8Encoder() {
    _init();
  }

  /// Creates a new [JsonFormatter].
  ///
  /// Optional [formatLevel], [formatTimestamp] and [formatFields] callbacks
  /// may be provided used to format severity levels, timestamp and collection
  /// fields respectively.
  // ignore: sort_unnamed_constructors_first
  factory JsonFormatter(
      {LevelFormatter<Object> formatLevel = _formatLevel,
      TimestampFormatter<Object> formatTimestamp = _formatTimestamp}) {
    final formatter =
        JsonFormatter._(const JsonEncoder(), formatLevel, formatTimestamp);

    return formatter;
  }

  factory JsonFormatter.withIndent(final int indent,
          {LevelFormatter<Object> formatLevel = _formatLevel,
          TimestampFormatter<Object> formatTimestamp = _formatTimestamp}) =>
      JsonFormatter._(
          JsonEncoder.withIndent(' ' * indent), formatLevel, formatTimestamp);

  final Utf8Encoder _utf8;
  final JsonEncoder _json;

  final LevelFormatter<Object> formatLevel;
  final TimestampFormatter<Object> formatTimestamp;

  /// Returns a default [JSONFormatter].
  static JsonFormatter get defaultFormatter => JsonFormatter();

  @pragma('vm:prefer-inline')
  void _init() {
    setFieldFormatter(FieldKind.boolean, _formatPrimitiveField);
    setFieldFormatter(FieldKind.dateTime, _formatPrimitiveField);
    setFieldFormatter(FieldKind.double, _formatPrimitiveField);
    setFieldFormatter(FieldKind.duration, _formatPrimitiveField);
    setFieldFormatter(FieldKind.integer, _formatPrimitiveField);
    setFieldFormatter(FieldKind.number, _formatPrimitiveField);
    setFieldFormatter(FieldKind.string, _formatPrimitiveField);
    setFieldFormatter(FieldKind.object, _formatObjectField);
  }

  Iterable<MapEntry<String, Object>> _formatFields(Iterable<Field> fields) {
    if (fields == null || fields.isEmpty) {
      return null;
    }

    final entries = <MapEntry<String, Object>>[];

    for (final field in fields) {
      final handler = getFieldFormatter(field.kind);
      entries.add(handler(field));
    }

    return entries;
  }

  @pragma('vm:prefer-inline')
  MapEntry<String, Object> _formatObjectField(Field field) {
    final entries = _formatFields((field as Obj).value);
    final name = field.name;
    if (entries != null) {
      return MapEntry(name, Map.fromEntries(entries));
    }

    return MapEntry(name, null);
  }

  @pragma('vm:prefer-inline')
  MapEntry<String, Object> _formatPrimitiveField(Field<dynamic> field) =>
      MapEntry(field.name, field.value.toString());

  List<int> call(Record record) {
    final dict = Map.fromEntries([
      MapEntry('level', formatLevel(record.level)),
      MapEntry('message', record.message),
      MapEntry('name', record.name),
      MapEntry('timestamp', formatTimestamp(record.timestamp)),
      ...?_formatFields(record.fields),
    ]);

    return _utf8.convert(_json.convert(dict));
  }
}
