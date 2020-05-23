import 'dart:convert' show Utf8Encoder;

import 'package:jetlog/jetlog.dart' show Field, FieldKind, Obj, Record, Level;
import 'package:jetlog/src/formatters/formatter.dart';

const String _eol = '\r\n';

typedef FormatHandler = String Function(
    String name, String timestamp, String level, String message, String fields);

/// [TextFormatter] is used to encode [Record] to formatted string.
class TextFormatter {
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
  final FormatHandler format;
  final LevelFormatter<String> formatLevel;
  final TimestampFormatter<String> formatTimestamp;
  final FieldsFormatter<String> formatFields;

  /// Returns a new [TextFormatter] with set `format` callback.
  static TextFormatter get defaultFormatter =>
      TextFormatter((name, timestamp, level, message, fields) =>
          '$name $timestamp [$level]: $message $fields'.trim());

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
      formatFields(record.fields),
    );

    if (message.isEmpty) {
      return [];
    }

    return _utf8.convert('$message$_eol');
  }
}

String _formatLevel(Level level) => level.name;

String _formatTimestamp(DateTime timestamp) => timestamp.toString();

String _formatField(Field field, [String? owner]) {
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

String _formatFields(Iterable<Field>? fields) => (StringBuffer()
      ..writeAll(<String>[
        if (fields != null) for (final f in fields) _formatField(f)
      ]))
    .toString()
    .trim();
