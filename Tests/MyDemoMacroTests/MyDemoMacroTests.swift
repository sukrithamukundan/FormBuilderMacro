import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(MyDemoMacroMacros)
    import MyDemoMacroMacros

    let testMacros: [String: Macro.Type] = [
        "stringify": StringifyMacro.self,
        "FormBuilder": FormBuilderMacro.self,
    ]
#endif

final class MyDemoMacroTests: XCTestCase {
    func testFormBuilder() throws {
        assertMacroExpansion("""
        @FormBuilder
        struct EditContact: View {
            @State var name: String
            @State var number: String
            @State var isFavourite: Bool
        }
        """, expandedSource: """
        struct EditContact: View {
            @State var name: String
            @State var number: String
            @State var isFavourite: Bool

            var body: some View {
                Form {
                    TextField("Enter name", text: $name)
                    TextField("Enter number", text: $number)
                    Toggle("isFavourite", isOn: $isFavourite)
                }
            }
        }
        """, macros: testMacros)
    }

    func testMacro() throws {
        #if canImport(MyDemoMacroMacros)
            assertMacroExpansion(
                """
                #stringify(a + b)
                """,
                expandedSource: """
                (a + b, "a + b")
                """,
                macros: testMacros
            )
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroWithStringLiteral() throws {
        #if canImport(MyDemoMacroMacros)
            assertMacroExpansion(
                #"""
                #stringify("Hello, \(name)")
                """#,
                expandedSource: #"""
                ("Hello, \(name)", #""Hello, \(name)""#)
                """#,
                macros: testMacros
            )
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
