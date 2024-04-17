@attached(member, names: named(init(from:)), named(encode(to:)), arbitrary)
@attached(extension, conformances: Codable)
public macro Codable() = #externalMacro(module: "SweetCodableMacros", type: "Codable")

@attached(member, names: named(init(from:)), named(encode(to:)), arbitrary)
public macro SubCodable() = #externalMacro(module: "SweetCodableMacros", type: "SubCodable")

@attached(peer)
public macro CodingKey(_ keys: String ...) = #externalMacro(module: "SweetCodableMacros", type: "CodingKey")
