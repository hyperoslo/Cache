import Foundation

/**
 Every type that conforms to this protocol can be
 encoded to and decoded from data
 */
public protocol Cachable {
  associatedtype CacheType
  /**
   Creates an instance from NSData

   - Parameter data: Data to decode from
   */
  static func decode(_ data: Data) -> CacheType?

  /**
   Encodes an instance to NSData
   */
  func encode() -> Data?
}
