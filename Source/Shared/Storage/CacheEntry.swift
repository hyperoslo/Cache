/// A wrapper around cached object and its expiry date.
public struct CacheEntry<T> {
  public let object: T
  public let expiry: Expiry
}
