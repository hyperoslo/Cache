//: Playground - noun: a place where people can play

import Cache

struct User {

  var id: Int
  var firstName: String
  var lastName: String

  var name: String {
    return "\(firstName) \(lastName)"
  }

  init(id: Int, firstName: String, lastName: String) {
    self.id = id
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

let cache = Cache<User>(name: "UserCache")
let user = User(firstName: "John", lastName: "Snow")

cache.add("\(user.id)", object: user) {
  print("Object has been added to memory and disk caches")
}

cache.object(key) { (user: User?) in
  print(user?.name)
}
