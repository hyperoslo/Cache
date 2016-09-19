import Foundation

// MARK: - Cachable

/**
 Implementation of Cachable protocol.
 */
extension String: Cachable {

  public typealias CacheType = String

  /**
   Creates a string from NSData

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
   Encodes a string to NSData
   - Returns: Optional NSData
   */
  public func encode() -> Data? {
    return data(using: String.Encoding.utf8)
  }
}

// MARK: - Helpers

/**
 Helper String extension.
 */
extension String {

  /**
   Creates base64 string

   - Returns: A base64 encoded string
   */
  func base64() -> String {
    guard let data = self.data(using: String.Encoding.utf8) else { return self }
    return data.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
  }
}
