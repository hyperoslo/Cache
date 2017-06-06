import Foundation

/**
 SpecializedCache is type safe cache, works with objects that conform to
 Cachable protocol. It's two layered cache (with front and back storages).
 Subscribes to system notifications to clear expired cached objects.
 */
public final class SpecializedCache<T: Cachable>: BasicHybridCache {
  /**
   Adds passed object to the front and back cache storages.
   - Parameter key: Unique key to identify the object in the cache
   - Parameter object: Object that needs to be cached
   - Parameter expiry: Expiration date for the cached object
   - Parameter completion: Completion closure to be called when the task is done
   */
  public func add(_ key: String, object: T, expiry: Expiry? = nil, completion: Completion? = nil) {
    return super.add(object, forKey: key, expiry: expiry, completion: completion)
  }

  /**
   Tries to retrieve the object from to the front and back cache storages.
   - Parameter key: Unique key to identify the object in the cache
   - Parameter completion: Completion closure to be called when the task is done
   */
  public func object(_ key: String, completion: @escaping (T?) -> Void) {
    return super.object(forKey: key, completion: completion)
  }

  /**
   Tries to retrieve the cache entry from to the front and back cache storages.
   - Parameter key: Unique key to identify the cache entry in the cache
   - Parameter completion: Completion closure to be called when the task is done
   */
  public func cacheEntry(_ key: String, completion: @escaping (CacheEntry<T>?) -> Void) {
    return super.cacheEntry(forKey: key, completion: completion)
  }
}
