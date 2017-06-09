import Foundation

/**
 SpecializedCache is type safe cache, works with objects that conform to
 Cachable protocol. It's two layered cache (with front and back storages).
 Subscribes to system notifications to clear expired cached objects.
 */
public final class SpecializedCache<T: Cachable>: BasicHybridCache {
  /// Async cache wrapper
  public private(set) lazy var async: AsyncSpecializedCache<T> = .init(manager: self.manager)

  /**
   Subscript wrapper around `object`, `addObject`, `removeObject` methods
   - Parameter key: Unique key to identify the object in the cache
   - Returns: Object from cache of nil
   */
  public subscript(key: String) -> T? {
    get {
      return object(forKey: key)
    }
    set(newValue) {
      do {
        if let value = newValue {
          try addObject(value, forKey: key)
        } else {
          try removeObject(forKey: key)
        }
      } catch {
        Logger.log(error: error)
      }
    }
  }

  /**
   Adds passed object to the front and back cache storages.
   - Parameter object: Object that needs to be cached
   - Parameter key: Unique key to identify the object in the cache
   - Parameter expiry: Expiration date for the cached object
   */
  public func addObject(_ object: T, forKey key: String, expiry: Expiry? = nil) throws {
    try manager.addObject(object, forKey: key, expiry: expiry)
  }

  /**
   Tries to retrieve the object from to the front and back cache storages.
   - Parameter key: Unique key to identify the object in the cache
   - Returns: Object from cache of nil
   */
  public func object(forKey key: String) -> T? {
    return manager.object(forKey: key)
  }

  /**
   Tries to retrieve the cache entry from to the front and back cache storages.
   - Parameter key: Unique key to identify the cache entry in the cache
   - Returns: Object from cache of nil
   */
  public func cacheEntry(forKey key: String) -> CacheEntry<T>? {
    return manager.cacheEntry(forKey: key)
  }

  /**
   Removes the object from to the front and back cache storages.
   - Parameter key: Unique key to identify the object in the cache
   */
  public func removeObject(forKey key: String) throws {
    try manager.removeObject(forKey: key)
  }

  /**
   Clears the front and back cache storages.
   - Parameter keepingRootDirectory: Pass `true` to keep the existing disk cache directory
   after removing its contents. The default value is `false`.
   */
  public func clear(keepingRootDirectory: Bool = false) throws {
    try manager.clear(keepingRootDirectory: keepingRootDirectory)
  }

  /**
   Clears all expired objects from front and back storages.
   */
  public func clearExpired() throws {
    try manager.clearExpired()
  }
}

/// Wrapper around async cache operations.
public class AsyncSpecializedCache<T: Cachable> {
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
  public func addObject(_ object: T, forKey key: String, expiry: Expiry? = nil,
                        completion: Completion? = nil) {
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
  public func removeObject(forKey key: String, completion: Completion? = nil) {
    manager.removeObject(forKey: key, completion: completion)
  }

  /**
   Clears the front and back cache storages.
   - Parameter keepingRootDirectory: Pass `true` to keep the existing disk cache directory
   after removing its contents. The default value is `false`.
   - Parameter completion: Completion closure to be called when the task is done
   */
  public func clear(keepingRootDirectory: Bool = false, completion: Completion? = nil) {
    manager.clear(keepingRootDirectory: keepingRootDirectory, completion: completion)
  }

  /**
   Clears all expired objects from front and back storages.
   - Parameter completion: Completion closure to be called when the task is done
   */
  public func clearExpired(completion: Completion? = nil) {
    manager.clearExpired(completion: completion)
  }
}
