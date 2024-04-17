# Requirements

| Xcode     | Minimun Deployments | Version                                          |
| --------- | ------------------- | ------------------------------------------------ |
| Xcode15   | >= iOS13 / macOS11  | 1.0.0                                            |
| < Xcode15 | < iOS13 / macOS11   | [1.0.1](https://github.com/Jowsing/SweetCodable) |

# About

The project objective is to enhance the usage experience of the Codable protocol using the macro provided by Swift 5.9 and to address the shortcomings of various official versions.

# Feature

- Transformer

## Installation

#### Cocoapods

`pod 'SweetCodable', '1.0.1'`

#### Swift Package Manager

`https://github.com/Jowsing/SweetCodable`

# Example

```swift
@Codable
struct Demo {
    var a: String = "hello world"
    var b: String = Bool.random() ? "hello world" : ""
    let c: String
    let d: String?
    let e: Int?

    @CodingKey("hello")
    var hi: String = "ok"
}
```

# Macro usage

## @Codable

- Auto conformance `Codable` protocol if not explicitly declared

  ```swift
  // both below works well

  @Codable
  struct Demo {}

  @Codable
  struct Demo: Codable {}
  ```

- Default value

  ```swift
  @Codable
  struct Test {
      let name: String
      var balance: Double = 0
  }

  // { "name": "jowsing" }
  ```

- Basic type automatic convertible, between `String` `Bool` `Number` etc.

  ```swift
  @Codable
  struct Test {
      let num: Int?
  }

  // { "num": "911" }
  ```

- Default Init

  ```swift
  @Codable
  public struct Test {
      public var name: String = "jowsing"

      // Automatic generated
      public init() {
          self.name = "jowsing"
      }
  }
  ```

## @CodingKey

- Custom `CodingKey`s

  ```swift
  @Codable
  struct Test {
      @CodingKey("s1", "s2", "s4")
      var str: String = ""
  }

  // { "s4": "jowsing" }
  ```
## @SubCodable

- Automatic generate `Codable` class's subclass `init(from:)` and `encode(to:)` super calls

  ```swift
  @Codable
  class BaseModel {
      let name: String
  }

  @SubCodable
  class SubModel: BaseModel {
      let age: Int
  }

  // {"name": "jowsing", "age": 22}
  ```