import 'dart:convert' show utf8;

import 'package:jetlog/jetlog.dart' show Field, FieldKind, Obj, Record, Level;
import 'package:jetlog/src/formatters/formatter.dart';

const String _eol = '\r\n';

typedef FormatHandler = String Function(
    String name, String timestamp, String level, String message, String fields);

@pragma('vm:prefer-inline')
String _formatPrimitiveField(Field field, String parent) {
  if (parent.isNotEmpty) {
    return '$parent.${field.name}=${field.value}';
  }

  return '${field.name}=${field.value}';
}

@pragma('vm:prefer-inline')
String _formatObjectField(Field field, String parent) {
  final fields = (field as Obj).value;

  if (fields == null) {
    String result = '${field.name}=null';
    if (parent.isNotEmpty) {
      result = '$parent.$result';
    }

    return result;
  }

  if (fields.isEmpty) {
    return '';
  }

  final buffer = StringBuffer();

  for (final childField in fields) {
    String nextParent = field.name;
    if (parent.isNotEmpty) {
      nextParent = '$parent.$nextParent';
    }

    if (childField.kind == FieldKind.object) {
      buffer.write(_formatObjectField(childField, nextParent));
    } else {
      buffer.write(_formatPrimitiveField(childField, nextParent));
    }

    buffer.write(' ');
  }

  return buffer.toString().trim();
}

@pragma('vm:prefer-inline')
String _formatLevel(Level level) => level.name;

@pragma('vm:prefer-inline')
String _formatTimestamp(DateTime timestamp) => timestamp.toString();

@pragma('vm:prefer-inline')
String _defaultFormatPrimitiveField(Field field) =>
    _formatPrimitiveField(field, '');

@pragma('vm:prefer-inline')
String _defaultFormatObjectField(Field field) => _formatObjectField(field, '');

/// [TextFormatter] is used to encode [Record] to formatted string.
class TextFormatter with FormatterBase<String> {
  /// Creates a new [TextFormatter] instance with [format] callback used to
  /// composite the final logging message.
  ///
  /// Optional [formatLevel], [formatTimestamp] callbacks may
  /// be also provided used to encode [Level], record timestamp and
  /// bound [Field] set (if any).
  ///
  /// [format] callback takes already encoded level, time and field sets as
  /// well as logger name and logged message.
  TextFormatter(
    this.format, {
    this.formatLevel = _formatLevel,
    this.formatTimestamp = _formatTimestamp,
  }) {
    _init();
  }

  /// Creates a new [TextFormatter] with set `format` callback.
  factory TextFormatter.withDefaults() =>
      TextFormatter((name, timestamp, level, message, fields) =>
          '$name $timestamp [$level]: $message $fields'.trim());

  final FormatHandler format;
  final LevelFormatter<String> formatLevel;
  final TimestampFormatter<String> formatTimestamp;

  @pragma('vm:prefer-inline')
  void _init() {
    setFieldFormatter(FieldKind.boolean, _defaultFormatPrimitiveField);
    setFieldFormatter(FieldKind.dateTime, _defaultFormatPrimitiveField);
    setFieldFormatter(FieldKind.double, _defaultFormatPrimitiveField);
    setFieldFormatter(FieldKind.duration, _defaultFormatPrimitiveField);
    setFieldFormatter(FieldKind.integer, _defaultFormatPrimitiveField);
    setFieldFormatter(FieldKind.number, _defaultFormatPrimitiveField);
    setFieldFormatter(FieldKind.string, _defaultFormatPrimitiveField);
    setFieldFormatter(FieldKind.object, _defaultFormatObjectField);
  }

  @pragma('vm:prefer-inline')
  String _formatFields(Iterable<Field>? fields) {
    if (fields == null || fields.isEmpty) {
      return '';
    }

    final buffer = StringBuffer();

    for (final field in fields) {
      final handler = getFieldFormatter(field.kind);

      buffer..write(handler(field))..write(' ');
    }

    return buffer.toString().trim();
  }

  /// Encodes given [record] to formatted string.
  ///
  /// If logger name isn't provided [format] callback receives empty string `''`
  /// instead of `null`.
  ///
  /// Each [record] is passed to [format] (with optionally preformatted `level`,
  /// `timestamp` and `fields` using [formatLevel], [formatTimestamp],
  /// [formatFields]) and finally formatted string is appended with `\r\n`.
  List<int> call(Record record) {
    final message = format(
      record.name ?? '',
      formatTimestamp(record.timestamp),
      formatLevel(record.level),
      record.message,
      _formatFields(record.fields),
    );

    if (message.isEmpty) {
      return [];
    }

    return utf8.encode('$message$_eol');
  }
}
