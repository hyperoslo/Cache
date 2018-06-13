import Foundation

/// Used to wrap Codable object
public struct TypeWrapper<T: Codable>: Codable {
  enum CodingKeys: String, CodingKey {
    case object
  }

  public let object: T

  public init(object: T) {
    self.object = object
  }
}
