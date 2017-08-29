import Foundation
@testable import Cache

struct User {
  let firstName: String
  let lastName: String
}

extension User: Coding {
  func encode(with aCoder: NSCoder) {
    aCoder.encode(firstName, forKey: "firstName")
    aCoder.encode(lastName, forKey: "lastName")
  }

  init?(coder aDecoder: NSCoder) {
    guard let firstName = aDecoder.decodeObject(forKey: "firstName") as? String else {
      return nil
    }
    guard let lastName = aDecoder.decodeObject(forKey: "lastName") as? String else {
      return nil
    }
    self.init(firstName: firstName, lastName: lastName)
  }
}
