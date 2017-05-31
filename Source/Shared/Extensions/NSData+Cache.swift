import Foundation

// MARK: - Cachable

/**
 Implementation of Cachable protocol.
 */
extension Data: Cachable {
  public typealias CacheType = Data

  /**
   Creates an instance from NSData
   - Parameter data: Data to decode from
   - Returns: An optional CacheType
   */
  public static func decode(_ data: Data) -> CacheType? {
    return data
  }

  /**
   Encodes an instance to NSData
   - Returns: Optional NSData
   */
  public func encode() -> Data? {
    return self
  }
}
