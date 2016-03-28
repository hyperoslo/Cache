import Foundation

public protocol Cachable {
  associatedtype CacheType

  static func decode(data: NSData) -> CacheType?
  func encode() -> NSData?
}
