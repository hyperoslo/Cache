import Foundation

public protocol DataConvertionAware {

  typealias CacheType

  func decode(data: NSData) throws -> CacheType
  func encode(var value: CacheType) throws -> NSData
}