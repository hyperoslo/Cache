import Foundation

/**
 Helper class to hold cached instance and expiry date.
 Used in memory storage to work with NSCache.
 */
final class Capsule: NSObject {

  /// Object to be cached
  let object: Any
  /// Expiration date
  let expiryDate: Date

  /// Checks if cached object is expired according to expiration date
  var expired: Bool {
    return expiryDate.inThePast
  }

  // MARK: - Initialization

  /**
   Creates a new instance of Capsule.

   - Parameter value: Object to be cached
   - Parameter expiry: Expiration date
   */
  init(value: Any, expiry: Expiry) {
    self.object = value
    self.expiryDate = expiry.date as Date
  }
}
