import Foundation

// MARK: - Cachable

/**
 Implementation of Cachable protocol.
 */
extension JSON: Cachable {

  public typealias CacheType = JSON

  /**
   Creates JSON from NSData

   - Parameter data: Data to decode from
   */
  public static func decode(data: NSData) -> CacheType? {
    var result: CacheType?

    do {
      let object = try NSJSONSerialization.JSONObjectWithData(data,
        options: NSJSONReadingOptions())

      switch (object) {
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
   */
  public func encode() -> NSData? {
    return try? NSJSONSerialization.dataWithJSONObject(object,
      options: NSJSONWritingOptions())
  }
}
