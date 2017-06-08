import Foundation

struct TestHelper {
  static var user: User {
    return User(firstName: "John", lastName: "Snow")
  }

  static func data(_ length : Int) -> Data {
    let buffer = [UInt8](repeating: 0, count: length)
    return Data(bytes: buffer)
  }
}
