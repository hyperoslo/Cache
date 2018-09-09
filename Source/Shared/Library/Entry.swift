import Foundation

/// A wrapper around cached object and its expiry date.
public struct Entry<T> {
  /// Cached object
  public let object: T
  /// Expiry date
  public let expiry: Expiry
  /// File path to the cached object
  public let filePath: String?
  /// Key for the finding the cached object
  public let key: String?

  init(object: T, expiry: Expiry, filePath: String? = nil, key: String? = nil) {
    self.object = object
    self.expiry = expiry
    self.filePath = filePath
    self.key = key
  }
}
