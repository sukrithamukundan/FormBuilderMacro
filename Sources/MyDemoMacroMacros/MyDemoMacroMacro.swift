import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Implementation of the `stringify` macro, which takes an expression
/// of any type and produces a tuple containing the value of that expression
/// and the source code that produced the value. For example
///
///     #stringify(x + y)
///
///  will expand to
///
///     (x + y, "x + y")
public struct StringifyMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        guard let argument = node.arguments.first?.expression else {
            fatalError("compiler bug: the macro does not have any arguments")
        }

        return "(\(argument), \(literal: argument.description))"
    }
}

// StructInitError
enum StructInitError: CustomStringConvertible, Error {
    case onlyApplicableToStruct

    var description: String {
        switch self {
        case .onlyApplicableToStruct: return "@StructInit can only be applied to a structure"
        }
    }
}

public struct FormBuilderMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Ensure the macro is applied to a struct
        guard let structDel = declaration.as(StructDeclSyntax.self) else {
            throw StructInitError.onlyApplicableToStruct
        }
        let members = structDel.memberBlock.members
        let variableDeclarations = members.compactMap { $0.decl.as(VariableDeclSyntax.self) }
        let variableNames = variableDeclarations.compactMap { $0.bindings.first?.pattern }
        let variableTypes = variableDeclarations.compactMap { $0.bindings.first?.typeAnnotation?.type }

        var body = """
        var body: some View {
            Form {

        """
        for (name, type) in zip(variableNames, variableTypes) {
            if type.as(IdentifierTypeSyntax.self)!.name.text == "String" {
                body += "TextField(\"Enter \(name)\", text: $\(name))"
            } else if type.as(IdentifierTypeSyntax.self)!.name.text == "Bool" {
                body += "Toggle(\"\(name)\", isOn: $\(name))"
            }
        }

        body += """
            }
        }
        """
        return [DeclSyntax(stringLiteral: body)]
    }
}

@main
struct MyDemoMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        StringifyMacro.self,
        FormBuilderMacro.self,
    ]
}

/*
 StructDeclSyntax
 ├─attributes: AttributeListSyntax
 │ ╰─[0]: AttributeSyntax
 │   ├─atSign: atSign
 │   ╰─attributeName: IdentifierTypeSyntax
 │     ╰─name: identifier("FormBuilder")
 ├─modifiers: DeclModifierListSyntax
 ├─structKeyword: keyword(SwiftSyntax.Keyword.struct)
 ├─name: identifier("EditContact")
 ├─inheritanceClause: InheritanceClauseSyntax
 │ ├─colon: colon
 │ ╰─inheritedTypes: InheritedTypeListSyntax
 │   ╰─[0]: InheritedTypeSyntax
 │     ╰─type: IdentifierTypeSyntax
 │       ╰─name: identifier("View")
 ╰─memberBlock: MemberBlockSyntax
   ├─leftBrace: leftBrace
   ├─members: MemberBlockItemListSyntax
   │ ├─[0]: MemberBlockItemSyntax
   │ │ ╰─decl: VariableDeclSyntax
   │ │   ├─attributes: AttributeListSyntax
   │ │   │ ╰─[0]: AttributeSyntax
   │ │   │   ├─atSign: atSign
   │ │   │   ╰─attributeName: IdentifierTypeSyntax
   │ │   │     ╰─name: identifier("State")
   │ │   ├─modifiers: DeclModifierListSyntax
   │ │   ├─bindingSpecifier: keyword(SwiftSyntax.Keyword.var)
   │ │   ╰─bindings: PatternBindingListSyntax
   │ │     ╰─[0]: PatternBindingSyntax
   │ │       ├─pattern: IdentifierPatternSyntax
   │ │       │ ╰─identifier: identifier("name")
   │ │       ╰─typeAnnotation: TypeAnnotationSyntax
   │ │         ├─colon: colon
   │ │         ╰─type: IdentifierTypeSyntax
   │ │           ╰─name: identifier("String")
   │ ├─[1]: MemberBlockItemSyntax
   │ │ ╰─decl: VariableDeclSyntax
   │ │   ├─attributes: AttributeListSyntax
   │ │   │ ╰─[0]: AttributeSyntax
   │ │   │   ├─atSign: atSign
   │ │   │   ╰─attributeName: IdentifierTypeSyntax
   │ │   │     ╰─name: identifier("State")
   │ │   ├─modifiers: DeclModifierListSyntax
   │ │   ├─bindingSpecifier: keyword(SwiftSyntax.Keyword.var)
   │ │   ╰─bindings: PatternBindingListSyntax
   │ │     ╰─[0]: PatternBindingSyntax
   │ │       ├─pattern: IdentifierPatternSyntax
   │ │       │ ╰─identifier: identifier("number")
   │ │       ╰─typeAnnotation: TypeAnnotationSyntax
   │ │         ├─colon: colon
   │ │         ╰─type: IdentifierTypeSyntax
   │ │           ╰─name: identifier("String")
   │ ╰─[2]: MemberBlockItemSyntax
   │   ╰─decl: VariableDeclSyntax
   │     ├─attributes: AttributeListSyntax
   │     │ ╰─[0]: AttributeSyntax
   │     │   ├─atSign: atSign
   │     │   ╰─attributeName: IdentifierTypeSyntax
   │     │     ╰─name: identifier("State")
   │     ├─modifiers: DeclModifierListSyntax
   │     ├─bindingSpecifier: keyword(SwiftSyntax.Keyword.var)
   │     ╰─bindings: PatternBindingListSyntax
   │       ╰─[0]: PatternBindingSyntax
   │         ├─pattern: IdentifierPatternSyntax
   │         │ ╰─identifier: identifier("isFavourite")
   │         ╰─typeAnnotation: TypeAnnotationSyntax
   │           ├─colon: colon
   │           ╰─type: IdentifierTypeSyntax
   │             ╰─name: identifier("Bool")
   ╰─rightBrace: rightBrace
 */
