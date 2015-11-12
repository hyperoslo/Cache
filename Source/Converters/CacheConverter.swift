import Foundation

public protocol CacheConverter {

  typealias CacheType

  func decode(data: NSData) throws -> CacheType
  func encode(var value: CacheType) throws -> NSData
}