import Foundation
@testable import Cache

struct User: Codable {
  let firstName: String
  let lastName: String

  enum CodingKeys: String, CodingKey {
    case firstName = "first_name"
    case lastName = "last_name"
  }
}
