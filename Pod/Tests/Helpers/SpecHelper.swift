import Foundation

class User: Cachable {

  typealias CacheType = User

  var firstName: String
  var lastName: String

  init(firstName: String, lastName: String) {
    self.firstName = firstName
    self.lastName = lastName
  }
}
