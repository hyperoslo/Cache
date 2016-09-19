import Foundation
@testable import Cache

struct User {

  var firstName: String
  var lastName: String

  init(firstName: String, lastName: String) {
    self.firstName = firstName
    self.lastName = lastName
  }
}

extension User: Cachable {

  typealias CacheType = User

  static func decode(_ data: Data) -> CacheType? {
    var object: User?

    do {
      object = try DefaultCacheConverter<User>().decode(data)
    } catch {}

    return object
  }

  func encode() -> Data? {
    var data: Data?

    do {
      data = try DefaultCacheConverter<User>().encode(self)
    } catch {}

    return data
  }
}
