import 'package:macros/macros.dart';

macro class Loggable
    implements ClassTypesMacro, ClassDefinitionMacro, ClassDeclarationsMacro {
  const Loggable();

  @override
  Future<void> buildTypesForClass(
      ClassDeclaration clazz, ClassTypeBuilder builder) async {
    // Add "implements Loggable"
    final loggable = await builder.resolveIdentifier(
        Uri.parse('package:jetlog/fields.dart'), 'Loggable');

    builder.appendInterfaces([NamedTypeAnnotationCode(name: loggable)]);
  }

  @override
  Future<void> buildDeclarationsForClass(
      ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    final fields = await builder.fieldsOf(clazz);
    print(fields);
  }

  @override
  Future<void> buildDefinitionForClass(
      ClassDeclaration clazz, TypeDefinitionBuilder builder) async {}
}

/// Field marks a class member as a loggable field.
class Field {
  const Field(this.name);

  final String name;
}

const field = Field("");
