//: Playground - noun: a place where people can play

import UIKit
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

// Implement Cachable protocol to be able to cache your object

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
let user = User(id: 1, firstName: "John", lastName: "Snow")
let key1 = "\(user.id)"
let key = "\(user.id)-copy"

// Add objects to the cache

cache.add(key, object: user)
cache.add(key, object: user)

// Fetch object from the cache

cache.object(key) { (user: User?) in
  print(user?.name)
}

// Remove object from the cache

cache.remove(key)

// Try to fetch removed object from the cache

cache.object(key) { (user: User?) in
  print(user?.name)
}

// Clear cache

cache.clear()
