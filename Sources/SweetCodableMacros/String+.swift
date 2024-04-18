import Foundation

extension String {
    func removeLastSpace() -> String {
        if hasSuffix(" ") {
            return String(prefix(count - 1)).removeLastSpace()
        }
        return self
    }
}
