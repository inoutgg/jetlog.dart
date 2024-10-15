import 'package:jetlog/src/field.dart';
import 'package:jetlog/src/record.dart';
import 'package:jetlog/src/record_impl.dart';

abstract class RedactPolicy {
  const RedactPolicy();

  factory RedactPolicy.censor(final String censor) = _CensorRedactPolicy;
  factory RedactPolicy.remove() = _RemoveRedactPolicy;

  Iterable<Field> redact(Iterable<Field> r);
}

class _CensorRedactPolicy extends RedactPolicy {
  const _CensorRedactPolicy(this.censor);

  final String censor;

  Iterable<Field> redact(Iterable<Field> fields) {
    return fields;
  }
}

class _RemoveRedactPolicy extends RedactPolicy {
  const _RemoveRedactPolicy();

  Iterable<Field> redact(Iterable<Field> fields) {
    return fields;
  }
}

// Possible patterns:
// foo.bar.*
// foo.*.bar
// *
class FieldsRedact {
  FieldsRedact(this.patterns, this.policy);

  final List<String> patterns;
  final RedactPolicy policy;

  Record redact(Record r) {
    final origFields = r.fields;
    Iterable<Field<dynamic>>? newFields;
    if (r.fields != null) {
      newFields = policy.redact(origFields!);
    }

    return RecordImpl(
        level: r.level,
        timestamp: r.timestamp,
        message: r.message,
        fields: newFields,
        name: r.name);
  }
}
