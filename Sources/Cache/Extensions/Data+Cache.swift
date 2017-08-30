import Foundation

// MARK: - Cachable

/**
 Implementation of Cachable protocol.
 */
extension Data: Cachable {
  public typealias CacheType = Data

  /**
   Creates an instance from Data.
   - Parameter data: Data to decode from
   - Returns: An optional CacheType
   */
  public static func decode(_ data: Data) -> CacheType? {
    return data
  }

  /**
   Encodes an instance to Data.
   - Returns: Optional Data
   */
  public func encode() -> Data? {
    return self
  }
}
