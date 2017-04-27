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
  public override func add<T: Cachable>(_ key: String, object: T, expiry: Expiry? = nil, completion: (() -> Void)? = nil) {
    super.add(key, object: object, expiry: expiry, completion: completion)
  }

  /**
   Tries to retrieve the object from to the front and back cache storages.

   - Parameter key: Unique key to identify the object in the cache
   - Parameter completion: Completion closure returns object or nil
   */
  public override func object<T: Cachable>(_ key: String, completion: @escaping (_ object: T?) -> Void) {
    super.object(key, completion: completion)
  }
}
