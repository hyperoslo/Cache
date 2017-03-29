import Foundation

/**
 Cache is type safe cache, works with objects that conform to
 Cachable protocol. It's two layered cache (with front and back storages).
 Subscribes to system notifications to clear expired cached objects.
 */
public final class Cache<T: Cachable>: HybridCache {

  // MARK: - Initialization

  /**
   Creates a new instance of Cache.

   - Parameter name: A name of the cache
   - Parameter config: Cache configuration
   */
  public override init(name: String, config: Config = Config.defaultConfig) {
    super.init(name: name, config: config)
  }

  // MARK: - Caching

  /**
   Adds passed object to the front and back cache storages.

   - Parameter key: Unique key to identify the object in the cache
   - Parameter object: Object that needs to be cached
   - Parameter expiry: Expiration date for the cached object
   - Parameter completion: Completion closure to be called when the task is done
   */
#if swift(>=3.1)
  public override func add<T: Cachable>(_ key: String, object: T, expiry: Expiry? = nil, completion: (() -> Void)? = nil) {
    super.add(key, object: object, expiry: expiry, completion: completion)
  }
#else
  public override func add(_ key: String, object: T, expiry: Expiry? = nil, completion: (() -> Void)? = nil) {
    super.add(key, object: object, expiry: expiry, completion: completion)
  }
#endif
  /**
   Tries to retrieve the object from to the front and back cache storages.

   - Parameter key: Unique key to identify the object in the cache
   - Parameter completion: Completion closure returns object or nil
   */
#if swift(>=3.1)
  public override func object<T: Cachable>(_ key: String, completion: @escaping (_ object: T?) -> Void) {
    super.object(key, completion: completion)
  }
#else
  public override func object(_ key: String, completion: @escaping (_ object: T?) -> Void) {
    super.object(key, completion: completion)
  }
#endif
}
