import SwiftSyntax
import SwiftSyntaxMacros

public struct SubCodable: MemberMacro {
    
    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        let container = try MemberContainer(decl: declaration)
        let decoderInit = try container.genDecoderInit(config: .init(override: true))
        let encodeFunc = try container.genEncodeFunc(config: .init(override: true))
        return [decoderInit, encodeFunc]
    }
}
