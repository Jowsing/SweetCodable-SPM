import SweetCodable
import Foundation

struct NN: Codable, Defaultable {
    static var `default`: NN { self.init(name: "`default`") }
    
    let name: String
    
    init(name: String) {
        self.name = name
    }
}

@Codable
struct Test {
    @CodingKey("h")
    var m: String
    var nn = NN(name: "hihi")
    var h1 = ""
    var h2 = 0.0
    var h3 = false
    var h4 = 0
    var h5: NN?
}

func decode<T: Codable>(json: String) -> T? {
    guard let data = json.data(using: .utf8) else { return nil }
    return try? JSONDecoder().decode(T.self, from: data)
}

let json = """
{
    "h": 0,
    "h4": "1",
}
"""
let t: Test? = decode(json: json)
print(t ?? "decode result = nil")

