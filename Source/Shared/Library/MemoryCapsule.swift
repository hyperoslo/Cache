import Foundation

/// Helper class to hold cached instance and expiry date.
/// Used in memory storage to work with NSCache.
class MemoryCapsule: NSObject {
  /// Object to be cached
  let object: Any
  /// Expiration date
  let expiry: Expiry

  /**
   Creates a new instance of Capsule.
   - Parameter value: Object to be cached
   - Parameter expiry: Expiration date
   */
  init(value: Any, expiry: Expiry) {
    self.object = value
    self.expiry = expiry
  }
}
