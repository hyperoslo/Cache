import Foundation

/// A configuration struct
public struct CacheJSONOptions {
  /// Options used when creating Foundation objects from JSON data
  public static var readingOptions: JSONSerialization.ReadingOptions = JSONSerialization.ReadingOptions()
  /// Options for writing JSON data.
  public static var writeOptions: JSONSerialization.WritingOptions = JSONSerialization.WritingOptions()
}

// MARK: - Cachable

/**
 Implementation of Cachable protocol.
 */

extension JSON: Cachable {

  public typealias CacheType = JSON

  /**
   Creates JSON from NSData

   - Parameter data: Data to decode from
   - Returns: An optional CacheType
   */
  public static func decode(_ data: Data) -> CacheType? {
    var result: CacheType?

    do {
      let object = try JSONSerialization.jsonObject(with: data,
                                                              options: CacheJSONOptions.readingOptions)

      switch object {
      case let dictionary as [String : AnyObject]:
        result = JSON.dictionary(dictionary)
      case let array as [AnyObject]:
        result = JSON.array(array)
      default:
        result = nil
      }
    } catch {}

    return result
  }

  /**
   Encodes JSON to NSData

   - Returns: Optional NSData
   */
  public func encode() -> Data? {
    return try? JSONSerialization.data(withJSONObject: object,
      options: CacheJSONOptions.writeOptions)
  }
}
