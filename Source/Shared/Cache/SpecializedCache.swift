import Foundation

/**
 SpecializedCache is type safe cache, works with objects that conform to
 Cachable protocol. It's two layered cache (with front and back storages).
 Subscribes to system notifications to clear expired cached objects.
 */
public final class SpecializedCache<T: Cachable>: BasicHybridCache {
  /// Async cache wrapper
  public private(set) lazy var async: AcyncSpecializedCache<T> = .init(manager: self.manager)

  /**
   Adds passed object to the front and back cache storages.
   - Parameter object: Object that needs to be cached
   - Parameter key: Unique key to identify the object in the cache
   - Parameter expiry: Expiration date for the cached object
   */
  func addObject(_ object: T, forKey key: String, expiry: Expiry? = nil) throws {
    try manager.addObject(object, forKey: key, expiry: expiry)
  }

  /**
   Tries to retrieve the object from to the front and back cache storages.
   - Parameter key: Unique key to identify the object in the cache
   - Returns: Object from cache of nil
   */
  func object(forKey key: String) -> T? {
    return manager.object(forKey: key)
  }

  /**
   Tries to retrieve the cache entry from to the front and back cache storages.
   - Parameter key: Unique key to identify the cache entry in the cache
   - Returns: Object from cache of nil
   */
  func cacheEntry(forKey key: String) -> CacheEntry<T>? {
    return manager.cacheEntry(forKey: key)
  }

  /**
   Removes the object from to the front and back cache storages.
   - Parameter key: Unique key to identify the object in the cache
   */
  func removeObject(forKey key: String) throws {
    try manager.removeObject(forKey: key)
  }

  /**
   Clears the front and back cache storages.
   */
  func clear() throws {
    try manager.clear()
  }

  /**
   Clears all expired objects from front and back storages.
   */
  func clearExpired() throws {
    try manager.clearExpired()
  }
}

/// Wrapper around async cache operations.
public class AcyncSpecializedCache<T: Cachable> {
  /// Cache manager
  private let manager: CacheManager

  /**
   Creates a new instance of AcycnHybridCache.
   - Parameter manager: Cache manager
   */
  init(manager: CacheManager) {
    self.manager = manager
  }

  /**
   Adds passed object to the front and back cache storages.
   - Parameter object: Object that needs to be cached
   - Parameter key: Unique key to identify the object in the cache
   - Parameter expiry: Expiration date for the cached object
   - Parameter completion: Completion closure to be called when the task is done
   */
  public func addObject(_ object: T, forKey key: String, expiry: Expiry? = nil, completion: Completion?) {
    manager.addObject(object, forKey: key, expiry: expiry, completion: completion)
  }

  /**
   Tries to retrieve the object from to the front and back cache storages.
   - Parameter key: Unique key to identify the object in the cache
   - Parameter completion: Completion closure to be called when the task is done
   */
  public func object(forKey key: String, completion: @escaping (T?) -> Void) {
    manager.object(forKey: key, completion: completion)
  }

  /**
   Tries to retrieve the cache entry from to the front and back cache storages.
   - Parameter key: Unique key to identify the cache entry in the cache
   - Parameter completion: Completion closure to be called when the task is done
   */
  public func cacheEntry(forKey key: String, completion: @escaping (CacheEntry<T>?) -> Void) {
    manager.cacheEntry(forKey: key, completion: completion)
  }

  /**
   Removes the object from to the front and back cache storages.
   - Parameter key: Unique key to identify the object in the cache
   - Parameter completion: Completion closure to be called when the task is done
   */
  public func removeObject(forKey key: String, completion: Completion?) {
    manager.removeObject(forKey: key, completion: completion)
  }

  /**
   Clears the front and back cache storages.
   - Parameter completion: Completion closure to be called when the task is done
   */
  public func clear(completion: Completion?) {
    manager.clear(completion: completion)
  }

  /**
   Clears all expired objects from front and back storages.
   - Parameter completion: Completion closure to be called when the task is done
   */
  public func clearExpired(completion: Completion?) {
    manager.clearExpired(completion: completion)
  }
}
