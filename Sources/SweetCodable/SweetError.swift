import Foundation

public struct SweetError: Error, CustomStringConvertible {
    
    let msg: String
    
    public var description: String {
        return msg
    }
}
