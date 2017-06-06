import Foundation

/**
 Defines basic cache behaviour
 */
protocol CacheAware {
  /**
   Saves passed object in the cache.
   - Parameter key: Unique key to identify the object in the cache
   - Parameter object: Object that needs to be cached
   - Parameter expiry: Expiration date for the cached object
   */
  func add<T: Cachable>(_ key: String, object: T, expiry: Expiry) throws

  /**
   Tries to retrieve the object from the cache.
   - Parameter key: Unique key to identify the object in the cache
   - Returns: Cached object or nil if not found
   */
  func object<T: Cachable>(_ key: String) throws -> T?

  /**
   Get cache entry which includes object with metadata.
   - Parameter key: Unique key to identify the object in the cache
   - Returns: Object wrapper with metadata or nil if not found
   */
  func cacheEntry<T: Cachable>(_ key: String) throws -> CacheEntry<T>?

  /**
   Removes the object from the cache by the given key.
   - Parameter key: Unique key to identify the object in the cache
   */
  func remove(_ key: String) throws

  /**
   Removes the object from the cache if it's expired.
   - Parameter key: Unique key to identify the object in the cache
   */
  func removeIfExpired(_ key: String) throws

  /**
   Removes all objects from the cache storage.
   */
  func clear() throws

  /**
   Removes all expired objects from the cache storage.
   */
  func clearExpired() throws
}
