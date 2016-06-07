import Foundation

/// A configuration enum
public enum CacheJSONOptions {
  /// Options used when creating Foundation objects from JSON data
  public static var readingOptions: NSJSONReadingOptions = NSJSONReadingOptions()
  /// Options for writing JSON data.
  public static var writeOptions: NSJSONWritingOptions = NSJSONWritingOptions()
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
  public static func decode(data: NSData) -> CacheType? {
    var result: CacheType?

    do {
      let object = try NSJSONSerialization.JSONObjectWithData(data,
                                                              options: CacheJSONOptions.readingOptions)

      switch object {
      case let dictionary as [String : AnyObject]:
        result = JSON.Dictionary(dictionary)
      case let array as [AnyObject]:
        result = JSON.Array(array)
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
  public func encode() -> NSData? {
    return try? NSJSONSerialization.dataWithJSONObject(object,
      options: CacheJSONOptions.writeOptions)
  }
}
