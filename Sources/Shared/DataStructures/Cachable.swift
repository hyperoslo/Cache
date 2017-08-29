import Foundation

/**
 Every type that conforms to this protocol can be
 encoded to and decoded from data
 */
public protocol Cachable {
  associatedtype CacheType
  /**
   Creates an instance from Data
   - Parameter data: Data to decode from
   */
  static func decode(_ data: Data) -> CacheType?

  /**
   Encodes an instance to Data
   */
  func encode() -> Data?
}
