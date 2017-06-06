import Foundation

/**
 Memory cache storage based on NSCache
 */
final class MemoryStorage: CacheAware {
  /// Memory cache instance
  private let cache = NSCache<NSString, Capsule>()
  // Memory cache keys
  private var keys = Set<String>()

  // MARK: - Initialization

  /**
   Creates a new memory storage.
   - Parameter name: A name of the storage
   - Parameter countLimit: The maximum number of objects the cache should hold.
   - Parameter totalCostLimit: The maximum total cost that the cache can hold before it starts evicting objects.
   */
  required init(name: String, countLimit: UInt = 0, totalCostLimit: UInt = 0) {
    cache.countLimit = Int(countLimit)
    cache.totalCostLimit = Int(totalCostLimit)
    cache.name = name
  }

  // MARK: - CacheAware

  /**
   Saves passed object in the memory.
   - Parameter key: Unique key to identify the object in the cache
   - Parameter object: Object that needs to be cached
   - Parameter expiry: Expiration date for the cached object
   */
  func add<T: Cachable>(_ key: String, object: T, expiry: Expiry = .never) {
    let capsule = Capsule(value: object, expiry: expiry)
    cache.setObject(capsule, forKey: key as NSString)
    keys.insert(key)
  }

  /**
   Tries to retrieve the object from the memory storage.
   - Parameter key: Unique key to identify the object in the cache
   - Returns: Cached object or nil if not found
   */
  func object<T: Cachable>(_ key: String) -> T? {
    return (cacheEntry(key) as CacheEntry<T>?)?.object
  }

  /**
   Get cache entry which includes object with metadata.
   - Parameter key: Unique key to identify the object in the cache
   - Returns: Object wrapper with metadata or nil if not found
   */
  func cacheEntry<T: Cachable>(_ key: String) -> CacheEntry<T>? {
    guard let capsule = cache.object(forKey: key as NSString) else {
      return nil
    }
    guard let object = capsule.object as? T else {
      return nil
    }
    return CacheEntry(object: object, expiry: Expiry.date(capsule.expiryDate))
  }

  /**
   Removes the object from the cache by the given key.
   - Parameter key: Unique key to identify the object in the cache
   */
  func remove(_ key: String) {
    cache.removeObject(forKey: key as NSString)
    keys.remove(key)
  }

  /**
   Removes the object from the cache if it's expired.
   - Parameter key: Unique key to identify the object in the cache
   */
  func removeIfExpired(_ key: String) {
    if let capsule = cache.object(forKey: key as NSString), capsule.expired {
      remove(key)
    }
  }

  /**
   Removes all objects from the cache storage.
   */
  func clear() {
    cache.removeAllObjects()
  }

  /**
   Clears all expired objects.
   */
  func clearExpired() {
    let allKeys = keys
    for key in allKeys {
      removeIfExpired(key)
    }
  }
}
