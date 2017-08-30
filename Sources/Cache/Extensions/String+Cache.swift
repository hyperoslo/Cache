import Foundation

// MARK: - Cachable

/**
 Implementation of Cachable protocol.
 */
extension String: Cachable {
  public typealias CacheType = String

  /**
   Creates a string from Data.
   - Parameter data: Data to decode from
   - Returns: An optional CacheType
   */
  public static func decode(_ data: Data) -> CacheType? {
    guard let string = String(data: data, encoding: String.Encoding.utf8) else {
      return nil
    }

    return string
  }

  /**
   Encodes a string to Data.
   - Returns: Optional Data
   */
  public func encode() -> Data? {
    return data(using: String.Encoding.utf8)
  }
}
