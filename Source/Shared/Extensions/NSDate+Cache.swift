import Foundation

// MARK: - Cachable

extension NSDate: Cachable {

  public typealias CacheType = NSDate

  public static func decode(data: NSData) -> CacheType? {
    return NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSDate
  }

  public func encode() -> NSData? {
    return NSKeyedArchiver.archivedDataWithRootObject(self)
  }
}

// MARK: - Helpers

extension NSDate {

  var inThePast: Bool {
    return timeIntervalSinceNow < 0
  }
}
