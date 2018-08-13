import Foundation

/// A wrapper around cached object and its expiry date.
public struct Entry<T> {
  /// Cached object
  public let object: T
  /// Expiry date
  public let expiry: Expiry
  /// File path to the cached object
  public let filePath: String?

  init(object: T, expiry: Expiry, filePath: String? = nil) {
    self.object = object
    self.expiry = expiry
    self.filePath = filePath
  }
}
