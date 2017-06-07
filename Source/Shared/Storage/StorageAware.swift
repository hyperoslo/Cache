import Foundation

/**
 Defines basic cache behaviour.
 */
protocol StorageAware {
  /**
   Saves passed object in the cache.
   - Parameter object: Object that needs to be cached
   - Parameter key: Unique key to identify the object in the cache
   - Parameter expiry: Expiration date for the cached object
   */
  func addObject<T: Cachable>(_ object: T, forKey key: String, expiry: Expiry) throws

  /**
   Tries to retrieve the object from the cache.
   - Parameter key: Unique key to identify the object in the cache
   - Returns: Cached object or nil if not found
   */
  func object<T: Cachable>(forKey key: String) throws -> T?

  /**
   Get cache entry which includes object with metadata.
   - Parameter key: Unique key to identify the object in the cache
   - Returns: Object wrapper with metadata or nil if not found
   */
  func cacheEntry<T: Cachable>(forKey key: String) throws -> CacheEntry<T>?

  /**
   Removes the object from the cache by the given key.
   - Parameter key: Unique key to identify the object in the cache
   */
  func removeObject(forKey key: String) throws

  /**
   Removes the object from the cache if it's expired.
   - Parameter key: Unique key to identify the object in the cache
   */
  func removeObjectIfExpired(forKey key: String) throws

  /**
   Removes all objects from the cache storage.
   */
  func clear() throws

  /**
   Removes all expired objects from the cache storage.
   */
  func clearExpired() throws
}
