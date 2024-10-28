import 'dart:convert' show utf8, json, Codec;

import 'package:strlog/strlog.dart'
    show Field, FieldKind, Level, Obj, Record, Group;
import 'package:strlog/src/formatters/formatter.dart';

@pragma('vm:prefer-inline')
Map<String, Object> _formatLevel(Level level) =>
    <String, Object>{'name': level.name, 'severity': level.value};

@pragma('vm:prefer-inline')
String _formatTimestamp(DateTime timestamp) => timestamp.toString();

/// [JsonFormatter] is used to encode [Record] to JSON format.
///
/// Make sure that no fields with overlapping names are provided as
/// formatter de-duplicates collapsing fields, i.e. providing fields with
/// the same key results only to a single field is include into the output.
///
/// As such we strongly recommend not to put fields in to any collections
/// fields with key such as `level`, `message`, `name` and `timestamp`.
final class JsonFormatter with FormatterBase<MapEntry<String, Object?>> {
  JsonFormatter._(this.formatLevel, this.formatTimestamp)
      : _codec = json.fuse(utf8) {
    _init();
  }

  /// Creates a new [JsonFormatter].
  ///
  /// Optional [formatLevel] and [formatTimestamp] callbacks
  /// may be provided and are used to format severity levels and timestamp.
  // ignore: sort_unnamed_constructors_first
  factory JsonFormatter(
      {LevelFormatter<Object> formatLevel = _formatLevel,
      TimestampFormatter<Object> formatTimestamp = _formatTimestamp}) {
    final formatter = JsonFormatter._(formatLevel, formatTimestamp);

    return formatter;
  }

  /// Creates a new [JSONFormatter] with default configurations.
  factory JsonFormatter.withDefaults() => JsonFormatter();

  final Codec<Object?, List<int>> _codec;

  final LevelFormatter<Object> formatLevel;
  final TimestampFormatter<Object> formatTimestamp;

  @pragma('vm:prefer-inline')
  void _init() {
    setFieldFormatter(FieldKind.boolean, _formatPrimitiveField);
    setFieldFormatter(FieldKind.dateTime, _formatPrimitiveFieldToString);
    setFieldFormatter(FieldKind.double, _formatPrimitiveField);
    setFieldFormatter(FieldKind.duration, _formatPrimitiveFieldToString);
    setFieldFormatter(FieldKind.integer, _formatPrimitiveField);
    setFieldFormatter(FieldKind.number, _formatPrimitiveField);
    setFieldFormatter(FieldKind.string, _formatPrimitiveField);
    setFieldFormatter(FieldKind.object, _formatObjectField);
    setFieldFormatter(FieldKind.group, _formatGroupField);
  }

  Iterable<MapEntry<String, Object?>>? _formatFields(Iterable<Field>? fields) {
    if (fields == null || fields.isEmpty) {
      return null;
    }

    final entries = <MapEntry<String, Object?>>[];

    for (final field in fields) {
      final handler = getFieldFormatter(field.kind);
      entries.add(handler(field));
    }

    return entries;
  }

  @pragma('vm:prefer-inline')
  MapEntry<String, Map<String, Object?>?> _formatObjectField(Field field) {
    final entries = _formatFields((field as Obj).value);
    final name = field.name;
    if (entries != null) {
      return MapEntry(name, Map.fromEntries(entries));
    }

    return MapEntry(name, null);
  }

  @pragma('vm:prefer-inline')
  MapEntry<String, Map<String, Object?>?> _formatGroupField(Field field) {
    final entries = _formatFields((field as Group).value);
    final name = field.name;
    if (entries != null) {
      return MapEntry(name, Map.fromEntries(entries));
    }

    return MapEntry(name, null);
  }

  @pragma('vm:prefer-inline')
  MapEntry<String, Object?> _formatPrimitiveField(Field field) =>
      MapEntry(field.name, field.value);

  @pragma('vm:prefer-inline')
  MapEntry<String, Object?> _formatPrimitiveFieldToString(Field field) =>
      MapEntry(field.name, field.value.toString());

  List<int> call(Record record) {
    final dict = Map.fromEntries([
      MapEntry('level', formatLevel(record.level)),
      MapEntry('message', record.message),
      MapEntry('name', record.name),
      MapEntry('timestamp', formatTimestamp(record.timestamp)),
      ...?_formatFields(record.fields),
    ]);

    return _codec.encode(dict);
  }
}
