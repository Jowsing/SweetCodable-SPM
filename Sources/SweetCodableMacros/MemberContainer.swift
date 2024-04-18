import SwiftSyntax
import SwiftSyntaxMacros

class MemberContainer {
    struct Property {
        var name: String
        var type: String
        var modifiers: DeclModifierListSyntax = []
        var isOptional: Bool = false
        var customKeys: [String] = []
        var initializerExpr: String?

        var codingKeys: [String] {
            let raw = [name]
            if customKeys.isEmpty {
                return raw
            }
            return customKeys + raw
        }
    }
    
    var properties: [Property] = []
    
    private let decl: DeclGroupSyntax
    
    init(decl: DeclGroupSyntax) throws {
        self.decl = decl
        try fetchProperties()
    }
    
    private func fetchProperties() throws {
        let members = decl.memberBlock.members
        properties = try members.flatMap { member -> [Property] in
            guard let variable = member.decl.as(VariableDeclSyntax.self), variable.isStoredProperty else {
                return []
            }
            let patterns = variable.bindings.map(\.pattern)
            let names = patterns.compactMap({ $0.as(IdentifierPatternSyntax.self)?.identifier.text })
            return try names.map { name -> Property in
                guard let type = variable.inferType else {
                    throw SweetError("please declare property type: \(name)")
                }
                var property = Property(name: name, type: type)
                property.modifiers = variable.modifiers
                property.isOptional = variable.isOptionalType
                
                let attributes = variable.attributes
                
                if let customKeysMarco = attributes.first(where: { $0.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.description == "CodingKey" }) {
                    property.customKeys = customKeysMarco.as(AttributeSyntax.self)?.arguments?.as(LabeledExprListSyntax.self)?.compactMap({
                        $0.expression.description.replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "\\", with: "")
                    }) ?? []
                }
                
                if let initializer = variable.bindings.compactMap(\.initializer).first {
                    property.initializerExpr = initializer.value.description
                }
                
                return property
            }
        }
    }
}

extension MemberContainer {
    struct GenConfig {
        let override: Bool
    }
    
    struct AttributeOption: OptionSet {
        let rawValue: UInt

        static let open = AttributeOption(rawValue: 1 << 0)
        static let `public` = AttributeOption(rawValue: 1 << 1)
        static let required = AttributeOption(rawValue: 1 << 2)
    }
    
    private func attributesPrefix(option: AttributeOption) -> String {
        let hasPublicProperites = properties.contains(where: {
            $0.modifiers.contains(where: {
                $0.name.text == "public" || $0.name.text == "open"
            })
        })

        let modifiers = decl.modifiers.compactMap { $0.name.text }
        var attributes: [String] = []
        if option.contains(.open), modifiers.contains("open") {
            attributes.append("open")
        } else if option.contains(.public), hasPublicProperites || modifiers.contains("open") || modifiers.contains("public") {
            attributes.append("public")
        }
        if option.contains(.required), decl.is(ClassDeclSyntax.self) {
            attributes.append("required")
        }
        if !attributes.isEmpty {
            attributes.append("")
        }

        return attributes.joined(separator: " ")
    }
    
    func genDecoderInit(config: GenConfig) throws -> DeclSyntax {
        let body = properties.map { property -> String in
            let head = property.isOptional ? "try?" : "try"
            let body = "container.decode(keys: \(property.codingKeys), defaultValue: \(property.initializerExpr ?? "nil"))"
            return "self.\(property.name) = \(head) \(body)"
        }.joined(separator: "\n")
        
        let decoder: DeclSyntax =
        """
        \(raw: attributesPrefix(option: [.public, .required]))init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: AnyCodingKey.self)
            \(raw: body)\(raw: config.override ? "\ntry super.init(from: decoder)" : "")
        }
        """
        
        return decoder
    }
    
    func genEncodeFunc(config: GenConfig) throws -> DeclSyntax {
        let body = properties.map { property -> String in
            return "try container.encode(value: self.\(property.name), keys: \(property.codingKeys))"
        }.joined(separator: "\n")
        
        let encoder: DeclSyntax =
        """
        \(raw: attributesPrefix(option: [.open, .public]))\(raw: config.override ? "override " : "")func encode(to encoder: Encoder) throws {
            \(raw: config.override ? "try super.encode(to: encoder)\n" : "")var container = encoder.container(keyedBy: AnyCodingKey.self)
            \(raw: body)
        }
        """
        
        return encoder
    }
    
    func genDefaultInit(config: GenConfig) throws -> DeclSyntax {
        let params = properties.map { property -> String in
            let declare = "\(property.name): \(property.type)"
            if let initializerExpr = property.initializerExpr {
                return "\(declare) = \(initializerExpr)"
            } else if property.isOptional {
                return "\(declare) = nil"
            } else {
                return "\(declare) = \(property.type).default"
            }
        }.joined(separator: ", ")
        
        let body = properties.map { property -> String in
            return "self.\(property.name) = \(property.name)"
        }.joined(separator: "\n")
        
        let defaultInit: DeclSyntax =
        """
        \(raw: attributesPrefix(option: [.public]))init(\(raw: params)) {
            \(raw: body)\(raw: config.override ? "\nsuper.init()" : "")
        }
        """
        
        return defaultInit
    }
}
