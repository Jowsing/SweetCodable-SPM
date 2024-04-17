import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct SweetPlugin: CompilerPlugin {
    let providingMacros: [any Macro.Type] = [
        Codable.self,
        SubCodable.self,
        CodingKey.self,
    ]
}
