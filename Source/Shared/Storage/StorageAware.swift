import Foundation

/**
 Defines basic cache behaviour
 */
public protocol CacheAware {

  /**
   Saves passed object in the cache.

   - Parameter key: Unique key to identify the object in the cache
   - Parameter object: Object that needs to be cached
   - Parameter expiry: Expiration date for the cached object
   - Parameter completion: Completion closure to be called when the task is done
   */
  func add<T: Cachable>(_ key: String, object: T, expiry: Expiry, completion: (() -> Void)?)

  /**
   Tries to retrieve the object from the cache.

   - Parameter key: Unique key to identify the object in the cache
   - Parameter completion: Completion closure returns object or nil
   */
  func object<T: Cachable>(_ key: String, completion: @escaping (_ object: T?) -> Void)

  /**
   Removes the object from the cache by the given key.

   - Parameter key: Unique key to identify the object in the cache
   - Parameter completion: Completion closure to be called when the task is done
   */
  func remove(_ key: String, completion: (() -> Void)?)

  /**
   Removes the object from the cache if it's expired.

   - Parameter key: Unique key to identify the object in the cache
   - Parameter completion: Completion closure to be called when the task is done
   */
  func removeIfExpired(_ key: String, completion: (() -> Void)?)

  /**
   Clears the cache storage.

   - Parameter completion: Completion closure to be called when the task is done
   */
  func clear(_ completion: (() -> Void)?)

  /**
   Clears all expired objects.

   - Parameter completion: Completion closure to be called when the task is done
   */
  func clearExpired(_ completion: (() -> Void)?)
}

/**
 Defines basic storage properties
 */
public protocol StorageAware: CacheAware {
  /// Prefix used in the queue or cache names
  static var prefix: String { get }

  /// Storage root path
  var path: String { get }
  /// Maximum size of the cache storage
  var maxSize: UInt { get set }
  /// Queue for write operations
  var writeQueue: DispatchQueue { get }
  /// Queue for read operations
  var readQueue: DispatchQueue { get }

  /**
   Storage initialization.

   - Parameter name: A name of the storage
   - Parameter maxSize: Maximum size of the cache storage
   */
  init(name: String, maxSize: UInt)
}
