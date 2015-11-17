import Foundation

// MARK: - Cachable

extension NSData: Cachable {

  public typealias CacheType = NSData

  public static func decode(data: NSData) -> CacheType? {
    return data
  }

  public func encode() -> NSData? {
    return self
  }
}
