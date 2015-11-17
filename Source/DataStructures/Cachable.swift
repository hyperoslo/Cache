import Foundation

public protocol Cachable {
  typealias CacheType

  static func decode(data: NSData) -> CacheType?
  func encode() -> NSData?
}
