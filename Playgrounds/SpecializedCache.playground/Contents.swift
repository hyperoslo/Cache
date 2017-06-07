//: Playground - noun: a place where people can play
import PlaygroundSupport
import UIKit
import Cache

struct User {
  let id: Int
  let firstName: String
  let lastName: String

  var name: String {
    return "\(firstName) \(lastName)"
  }
}

// Implement Cachable protocol to be able to cache your object

extension User: Coding {
  func encode(with aCoder: NSCoder) {
    aCoder.encode(id, forKey: "id")
    aCoder.encode(firstName, forKey: "firstName")
    aCoder.encode(lastName, forKey: "lastName")
  }

  init?(coder aDecoder: NSCoder) {
    guard
      let id = aDecoder.decodeObject(forKey: "id") as? Int,
      let firstName = aDecoder.decodeObject(forKey: "firstName") as? String,
      let lastName = aDecoder.decodeObject(forKey: "lastName") as? String
      else { return nil }
    self.init(id: id, firstName: firstName, lastName: lastName)
  }
}

let cache = SpecializedCache<User>(name: "UserCache")
let user = User(id: 1, firstName: "John", lastName: "Snow")
let key = "\(user.id)"

// Add objects to the cache
try cache.addObject(user, forKey: key)

// Fetch object from the cache
cache.async.object(forKey: key) { (user: User?) in
  print(user?.name ?? "")
}

// Remove object from the cache
try cache.removeObject(forKey: key)

// Try to fetch removed object from the cache
cache.async.object(forKey: key) { (user: User?) in
  print(user?.name ?? " - ")
}

// Clear cache
try cache.clear()

PlaygroundPage.current.needsIndefiniteExecution = true