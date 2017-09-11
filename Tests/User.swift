import Foundation
@testable import Cache

struct User {
  let firstName: String
  let lastName: String
}

extension User: Cachable {
  public typealias CacheType = User

  public static func decode(_ data: Data) -> CacheType? {
    guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [String: Any] else {
      return nil
    }

    guard let firstName = json["firstName"] as? String else {
      return nil
    }

    guard let lastName = json["lastName"] as? String else {
      return nil
    }

    let user = User(firstName: firstName, lastName: lastName)
    return user
  }

  public func encode() -> Data? {
    let json = [
      "firstName": firstName,
      "lastName": lastName
    ]

    return try? JSONSerialization.data(withJSONObject: json, options: [])
  }
}
