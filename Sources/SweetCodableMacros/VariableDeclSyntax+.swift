import SwiftSyntax

extension VariableDeclSyntax {

    var isStoredProperty: Bool {
        if modifiers.compactMap({ $0.as(DeclModifierSyntax.self) }).contains(where: { $0.name.text == "static" }) {
            return false
        }
        if bindings.count < 1 {
            return false
        }
        let binding = bindings.last!
        switch binding.accessorBlock?.accessors {
        case .none:
            return true
        case let .accessors(o):
            for accessor in o {
                switch accessor.accessorSpecifier.tokenKind {
                case .keyword(.willSet), .keyword(.didSet):
                    // Observers can occur on a stored property.
                    break
                default:
                    // Other accessors make it a computed property.
                    return false
                }
            }
            return true
        case .getter:
            return false
        }
    }

    var inferType: String? {
        var type = bindings.compactMap(\.typeAnnotation).first?.type.description
        // try infer type
        if type == nil, let initExpr = bindings.compactMap(\.initializer).first?.value {
            if initExpr.is(StringLiteralExprSyntax.self) {
                type = "String"
            } else if initExpr.is(IntegerLiteralExprSyntax.self) {
                type = "Int"
            } else if initExpr.is(FloatLiteralExprSyntax.self) {
                type = "Double"
            } else if initExpr.is(BooleanLiteralExprSyntax.self) {
                type = "Bool"
            } else {
                var initExprStr = initExpr.description
                if initExprStr.hasSuffix("?") {
                    initExprStr = String(initExprStr.prefix(initExprStr.count - 1))
                }
                type = initExprStr
            }
        }
        return type
    }

    var isOptionalType: Bool {
        if bindings.compactMap(\.typeAnnotation).first?.type.is(OptionalTypeSyntax.self) == true {
            return true
        }
        if bindings.compactMap(\.initializer).first?.value.as(DeclReferenceExprSyntax.self)?.description.hasPrefix("Optional<") == true {
            return true
        }
        if bindings.compactMap(\.initializer).first?.value.as(DeclReferenceExprSyntax.self)?.description.hasPrefix("Optional(") == true {
            return true
        }
        return false
    }
}
