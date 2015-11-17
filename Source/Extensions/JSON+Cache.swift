import Foundation

// MARK: - Cachable

extension JSON: Cachable {

  public typealias CacheType = JSON

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

  public func encode() -> NSData? {
    return try? NSJSONSerialization.dataWithJSONObject(object,
      options: NSJSONWritingOptions())
  }
}
