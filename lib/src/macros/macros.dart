import 'package:macros/macros.dart';

final _fieldsFile = Uri.parse('package:jetlog/src/field.dart');

macro class Loggable
    implements ClassTypesMacro, ClassDefinitionMacro, ClassDeclarationsMacro {
  const Loggable();

  @override
  Future<void> buildTypesForClass(
      ClassDeclaration clazz, ClassTypeBuilder builder) async {
    // Add "implements Loggable"
    final loggable = await builder.resolveIdentifier(
        _fieldsFile, 'Loggable');
    
    builder.appendInterfaces([NamedTypeAnnotationCode(name: loggable)]);
  }

  @override
  Future<void> buildDeclarationsForClass(
      ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    final fields = await builder.fieldsOf(clazz);
    print(fields.map((f) {
      print(f.definingType.name);
      return f.identifier.name;
    }));
  }

  @override
  Future<void> buildDefinitionForClass(
      ClassDeclaration clazz, TypeDefinitionBuilder builder) async {
        final fields = await clazz.
        print(fields);
      }
}

/// Field marks a class member as a loggable field.
class Field {
  const Field(this.name);

  final String name;
}

const field = Field("");
