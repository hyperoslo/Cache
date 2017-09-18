import Foundation

/// A wrapper around cached object and its expiry date.
public struct Entry<T: Codable> {
  /// Cached object
  public let object: T
  /// Expiry date
  public let expiry: Expiry
  /// Associated meta data, if any
  public let meta: [String: Any]

  init(object: T, expiry: Expiry, meta: [String: Any] = [:]) {
    self.object = object
    self.expiry = expiry
    self.meta = meta
  }
}
