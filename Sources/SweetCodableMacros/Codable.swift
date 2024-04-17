import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxMacroExpansion

public struct Codable: MemberMacro, ExtensionMacro {
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol, conformingTo protocols: [SwiftSyntax.TypeSyntax], in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        var inheritedTypes: InheritedTypeListSyntax?
        if let declaration = declaration.as(StructDeclSyntax.self) {
            inheritedTypes = declaration.inheritanceClause?.inheritedTypes
        } else if let declaration = declaration.as(ClassDeclSyntax.self) {
            inheritedTypes = declaration.inheritanceClause?.inheritedTypes
        } else {
            throw SweetError("use @Codable in `struct` or `class`")
        }
        if let inheritedTypes = inheritedTypes,
           inheritedTypes.contains(where: { inherited in inherited.type.trimmedDescription == "Codable" })
        {
            return []
        }

        let ext: DeclSyntax =
            """
            extension \(type.trimmed): Codable {}
            """

        return [ext.cast(ExtensionDeclSyntax.self)]
    }
    
    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        let container = try MemberContainer(decl: declaration)
        let decoderInit = try container.genDecoderInit(config: .init(override: false))
        let encodeFunc = try  container.genEncodeFunc(config: .init(override: false))
        let defaultInit = try container.genDefaultInit(config: .init(override: false))
        return [decoderInit, encodeFunc, defaultInit]
    }
    
}
