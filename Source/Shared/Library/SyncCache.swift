import Foundation

/**
 Wrapper around type safe cache to work with cached data synchronously
 */
public struct SyncCache<T: Cachable> {

  /// Cache that requires sync operations
  let cache: Cache<T>

  // MARK: - Initialization

  /**
   Creates a wrapper around cache object.

   - Parameter cache: Cache that requires sync operations
   */
  public init(_ cache: Cache<T>) {
    self.cache = cache
  }

  // MARK: - Caching

  /**
   Adds passed object to the front and back cache storages.

   - Parameter key: Unique key to identify the object in the cache
   - Parameter object: Object that needs to be cached
   - Parameter expiry: Expiration date for the cached object
   */
  public func add(_ key: String, object: T, expiry: Expiry? = nil) {
    let semaphore = DispatchSemaphore(value: 0)

    cache.add(key, object: object, expiry: expiry) {
      semaphore.signal()
    }

    _ = semaphore.wait(timeout: DispatchTime.distantFuture)
  }

  /**
   Tries to retrieve the object from to the front and back cache storages.

   - Parameter key: Unique key to identify the object in the cache
   - Returns: Found object or nil
   */
  public func object(_ key: String) -> T? {
    var result: T?

    let semaphore = DispatchSemaphore(value: 0)

    cache.object(key) { (object: T?) in
      result = object
      semaphore.signal()
    }

    _ = semaphore.wait(timeout: DispatchTime.distantFuture)

    return result
  }

  /**
   Removes the object from to the front and back cache storages.

   - Parameter key: Unique key to identify the object in the cache
   */
  public func remove(_ key: String) {
    SyncHybridCache(cache).remove(key)
  }

  /**
   Clears the front and back cache storages.
   */
  public func clear() {
    SyncHybridCache(cache).clear()
  }
}
