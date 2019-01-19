import 'package:meta/meta.dart' show required;
import 'package:structlog/structlog.dart' show Field, FieldKind, Level, Record;

import 'package:structlog/src/formatters/bytes_formatter.dart';
import 'package:structlog/src/formatters/formatter.dart';

typedef LoggerNameFormatCallback = String Function(String);
typedef LevelFormatCallback = String Function(Level);
typedef FieldFormatCallback = String Function(Field);
typedef TimeFormatCallback = String Function(DateTime);

typedef FormatCallback = String Function(
    {String name, String level, String time, String message, String fields});

String _defaultFormatName(String name) => name ?? '';

String _defaultFormatLevel(Level level) => level.name;

String _defaultFormatTime(DateTime time) => time.toIso8601String();

String _defaultFormatFieldName(Field field, [String name]) {
  switch (field.kind) {
    case FieldKind.boolean:
    case FieldKind.dateTime:
    case FieldKind.double:
    case FieldKind.duration:
    case FieldKind.integer:
    case FieldKind.number:
    case FieldKind.string:
      {
        return name != null
            ? '$name.${field.name}=${field.value} '
            : '${field.name}=${field.value} ';
      }

    case FieldKind.object:
      {
        final result = StringBuffer();
        final fields = field.value as Iterable<Field>;

        for (final f in fields) {
          result.write(_defaultFormatFieldName(f, field.name));
        }

        return result.toString().trim();
      }

    default:
      {
        // TODO: find more appropriated error type.
        throw ArgumentError('Unknown field type!');
      }
  }
}

String _defaultFormatField(Field field) => _defaultFormatFieldName(field);

/// [TextFormatter] formats logging records to its text representation.
class TextFormatter implements Formatter<String> {
  /// Creates a new [TextFormatter] with format defined by [format] callback.
  ///
  /// The [format] takes already formatted record's name, level, time and fields
  /// values and composes its to the final record text representation.
  ///
  /// Record's level, time and fields values formatting are formatted using
  /// [formatLevel], [formatTime], [formatField] callbacks.
  TextFormatter(
      {@required FormatCallback format,
      LoggerNameFormatCallback formatName = _defaultFormatName,
      LevelFormatCallback formatLevel = _defaultFormatLevel,
      FieldFormatCallback formatField = _defaultFormatField,
      TimeFormatCallback formatTime = _defaultFormatTime})
      : _format = format,
        _formatName = formatName,
        _formatLevel = formatLevel,
        _formatTime = formatTime,
        _formatField = formatField;

  final LoggerNameFormatCallback _formatName;
  final LevelFormatCallback _formatLevel;
  final FormatCallback _format;
  final FieldFormatCallback _formatField;
  final TimeFormatCallback _formatTime;

  String _formatFields(Iterable<Field> fields) {
    if (fields != null) {
      final result = StringBuffer();

      for (final f in fields) {
        result.write(_formatField(f));
      }

      return result.toString().trim();
    }

    return '';
  }

  @override
  String format(Record record) {
    final name = _formatName(record.name);
    final level = _formatLevel(record.level);
    final time = _formatTime(record.time);
    final fields = _formatFields(record.fields);
    final result = _format(
        name: name,
        level: level,
        time: time,
        message: record.message,
        fields: fields);

    return result.trim();
  }

  /// Returns a formatter that formats records write into UTF-16 code units.
  Formatter<List<int>> get bytes => BytesFormatter(this);
}
