import Foundation

// MARK: - Cachable

/**
 Implementation of Cachable protocol.
 */
extension JSON: Cachable {
  public typealias CacheType = JSON

  /**
   Creates JSON from Data.
   - Parameter data: Data to decode from
   - Returns: An optional CacheType
   */
  public static func decode(_ data: Data) -> CacheType? {
    var result: CacheType?

    do {
      let object = try JSONSerialization.jsonObject(
        with: data,
        options: JSONSerialization.ReadingOptions()
      )

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
   Encodes JSON to Data.
   - Returns: Optional Data
   */
  public func encode() -> Data? {
    return try? JSONSerialization.data(
      withJSONObject: object,
      options: JSONSerialization.WritingOptions()
    )
  }
}
