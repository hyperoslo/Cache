import Foundation

/// A wrapper around cached object and its expiry date.
public struct Entry<T: Codable> {
  /// Cached object
  public let object: T
  /// Expiry date
  public let expiry: Expiry
}
