import 'dart:convert' show Utf8Encoder;

import 'package:structlog/structlog.dart'
    show Field, FieldKind, Obj, Record, Level;

import 'package:structlog/src/formatters/formatter.dart';

const String _eol = '\r\n';

/// [TextFormatter] is used to encode [Record] to formatted string.
class TextFormatter extends Formatter {
  /// Creates a new [TextFormatter] instance with [format] callback used to
  /// composite the final logging message.
  ///
  /// Optional [formatLevel], [formatTimestamp], [formatFields] callbacks may
  /// be also provided used to encode [Level], record timestamp and
  /// bound [Field] set (if any).
  ///
  /// [format] callback takes already encoded level, time and field sets as
  /// well as logger name and logged message.
  TextFormatter(
    this.format, {
    this.formatLevel = _formatLevel,
    this.formatTimestamp = _formatTimestamp,
    this.formatFields = _formatFields,
  }) : _utf8 = const Utf8Encoder();

  final Utf8Encoder _utf8;
  final FormatCallback<String, String, String, String> format;
  final LevelFormatCallback<String> formatLevel;
  final TimestampFormatCallback<String> formatTimestamp;
  final FieldsFormatCallback<String> formatFields;

  /// Encodes given [record] to formatted string.
  ///
  /// If logger name isn't provided [format] callback receives empty string `''`
  /// instead of `null`.
  ///
  /// Each [record] is passed to [format] (with optionally preformatted `level`,
  /// `timestamp` and `fields` using [formatLevel], [formatTimestamp],
  /// [formatFields]) and finally formatted string is appended with `\r\n`.
  @override
  List<int> call(Record record) {
    final message = format(
      name: record.name ?? '',
      level: formatLevel(record.level),
      timestamp: formatTimestamp(record.timestamp),
      message: record.message,
      fields: formatFields(record.fields),
    );

    if (message.isEmpty) {
      return [];
    }

    return _utf8.convert('$message$_eol');
  }
}

String _formatLevel(Level level) => level.name;

String _formatTimestamp(DateTime timestamp) => timestamp.toString();

String _formatField(Field field, [String owner]) {
  final buffer = StringBuffer();

  switch (field.kind) {
    case FieldKind.object:
      final fields = (field as Obj).value;

      buffer.writeAll(<String>[
        if (fields != null) for (final f in fields) _formatField(f, field.name)
      ]);
      break;

    default:
      if (owner != null) {
        buffer.write('$owner.');
      }

      buffer.write('${field.name}=${field.value} ');
  }

  return buffer.toString();
}

String _formatFields(Iterable<Field> fields) => (StringBuffer()
      ..writeAll(<String>[
        if (fields != null) for (final f in fields) _formatField(f)
      ]))
    .toString()
    .trim();
