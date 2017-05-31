/**
 HybridCache supports storing all kinds of objects, as long as they conform to
 Cachable protocol. It's two layered cache (with front and back storages), as well as Cache.
 Subscribes to system notifications to clear expired cached objects.
 */
public class HybridCache: BasicHybridCache {
  /**
   Adds passed object to the front and back cache storages.
   - Parameter key: Unique key to identify the object in the cache
   - Parameter object: Object that needs to be cached
   - Parameter expiry: Expiration date for the cached object
   - Parameter completion: Completion closure to be called when the task is done
   */
  public func add<T: Cachable>(_ key: String, object: T, expiry: Expiry? = nil, completion: (() -> Void)? = nil) {
    super.add(object, forKey: key, expiry: expiry, completion: completion)
  }

  /**
   Tries to retrieve the object from to the front and back cache storages.
   - Parameter key: Unique key to identify the object in the cache
   - Parameter completion: Completion closure returns object or nil
   */
  public func object<T: Cachable>(_ key: String, completion: @escaping (_ object: T?) -> Void) {
    super.object(forKey: key, completion: completion)
  }

  /**
   Tries to retrieve the cache entry from to the front and back cache storages.
   - Parameter key: Unique key to identify the cache entry in the cache
   - Parameter completion: Completion closure returns cache entry or nil
   */
  public func cacheEntry<T: Cachable>(_ key: String, completion: @escaping (_ object: CacheEntry<T>?) -> Void) {
    super.cacheEntry(forKey: key, completion: completion)
  }
}
