import Foundation

// MARK: - Cachable

/**
 Implementation of Cachable protocol.
 */
extension Date: Cachable {

  public typealias CacheType = Date

  /**
   Creates an instance from NSData

   - Parameter data: Data to decode from
   - Returns: An optional CacheType
   */
  public static func decode(_ data: Data) -> CacheType? {
    return NSKeyedUnarchiver.unarchiveObject(with: data) as? Date
  }

  /**
   Encodes an instance to NSData
   - Returns: Optional NSData
   */
  public func encode() -> Data? {
    return NSKeyedArchiver.archivedData(withRootObject: self)
  }
}

// MARK: - Helpers

/**
 Helper NSDate extension.
 */
extension Date {

  /// Checks if the date is in the past
  var inThePast: Bool {
    return timeIntervalSinceNow < 0
  }
}
