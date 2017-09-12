/// A wrapper around cached object and its expiry date.
public struct CacheEntry<T> {
  /// Cached object
  public let object: T
  /// Expiry date
  public let expiry: Expiry
}
