import Foundation

public extension KeyedDecodingContainer where Key == AnyCodingKey {
    
    func decode<T: Decodable>(keys: [String], defaultValue: @autoclosure () -> T?) throws -> T {
        for key in keys {
            if let value = smartDecode(key: key, type: T.self) {
                return value
            }
        }
        // Use the defaultValue value if not nil
        if let value = defaultValue() {
            return value
        }
        // Use the Defaultable.default value if need
        if let deType = T.self as? Defaultable.Type, let value = deType.default as? T {
            return value
        }
        throw SweetError(msg: "decode failure: keys: \(keys)")
    }
    
    private func smartDecode<T: Decodable>(key: String, type: T.Type) -> T? {
        guard let key = Key(stringValue: key) else { return nil }
        if let value = try? decode(type, forKey: key) { return value }
        if let anyValue = try? decode(AnyDecodable.self, forKey: key) {
            if let value = anyValue.value as? Convertable {
                return value.convert()
            }
        }
        return nil
    }
}
