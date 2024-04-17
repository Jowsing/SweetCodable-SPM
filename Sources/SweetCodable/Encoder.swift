import Foundation

public extension KeyedEncodingContainer where Key == AnyCodingKey {
    
    mutating func encode<T: Encodable>(value: T, keys: [String]) throws {
        let codingKey = AnyCodingKey(stringValue: keys[0])!
        try self.encode(value, forKey: codingKey)
    }
}
