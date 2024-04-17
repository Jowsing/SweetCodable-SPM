import Foundation

public protocol Defaultable {
    static var `default`: Self { get }
}

extension String: Defaultable {
    public static var `default`: String { "" }
}

extension Bool: Defaultable {
    public static var `default`: Bool { false }
}

extension Double: Defaultable {
    public static var `default`: Double { 0.0 }
}

extension Float: Defaultable {
    public static var `default`: Float { 0.0 }
}

extension Int: Defaultable {
    public static var `default`: Int { 0 }
}

extension UInt: Defaultable {
    public static var `default`: UInt { 0 }
}

extension Int8: Defaultable {
    public static var `default`: Int8 { 0 }
}

extension UInt8: Defaultable {
    public static var `default`: UInt8 { 0 }
}

extension Int16: Defaultable {
    public static var `default`: Int16 { 0 }
}

extension UInt16: Defaultable {
    public static var `default`: UInt16 { 0 }
}

extension Int32: Defaultable {
    public static var `default`: Int32 { 0 }
}

extension UInt32: Defaultable {
    public static var `default`: UInt32 { 0 }
}

extension Int64: Defaultable {
    public static var `default`: Int64 { 0 }
}

extension UInt64: Defaultable {
    public static var `default`: UInt64 { 0 }
}

extension Array: Defaultable {
    public static var `default`: Array { [] }
}

extension Dictionary: Defaultable {
    public static var `default`: Dictionary { [:] }
}
