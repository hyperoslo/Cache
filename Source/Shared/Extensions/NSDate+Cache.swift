import Foundation

// MARK: - Cachable

/**
 Implementation of Cachable protocol.
 */
extension NSDate: Cachable {

  public typealias CacheType = NSDate

  /**
   Creates an instance from NSData

   - Parameter data: Data to decode from
   */
  public static func decode(data: NSData) -> CacheType? {
    return NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSDate
  }

  /**
   Encodes an instance to NSData
   */
  public func encode() -> NSData? {
    return NSKeyedArchiver.archivedDataWithRootObject(self)
  }
}

// MARK: - Helpers

/**
 Helper NSDate extension.
 */
extension NSDate {

  /// Checks if the date is in the past
  var inThePast: Bool {
    return timeIntervalSinceNow < 0
  }
}
