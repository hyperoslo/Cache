import Foundation
@testable import Cache

struct User {
  let firstName: String
  let lastName: String
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
