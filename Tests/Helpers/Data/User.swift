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

  static func decode(data: NSData) -> CacheType? {
    var object: User?

    do {
      object = try DefaultCacheConverter<User>().decode(data)
    } catch {}

    return object
  }

  func encode() -> NSData? {
    var data: NSData?

    do {
      data = try DefaultCacheConverter<User>().encode(self)
    } catch {}
    
    return data
  }
}
