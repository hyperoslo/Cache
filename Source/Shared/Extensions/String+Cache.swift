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
   */
  public static func decode(data: NSData) -> CacheType? {
    guard let string = String(data: data, encoding: NSUTF8StringEncoding) else {
      return nil
    }

    return string
  }

  /**
   Encodes a string to NSData
   */
  public func encode() -> NSData? {
    return dataUsingEncoding(NSUTF8StringEncoding)
  }
}

// MARK: - Helpers

/**
 Helper String extension.
 */
extension String {

  /**
   Creates base64 string
   */
  func base64() -> String {
    guard let data = self.dataUsingEncoding(NSUTF8StringEncoding) else { return self }
    return data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
  }
}
