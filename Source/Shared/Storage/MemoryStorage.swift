import Foundation

/**
 Memory cache storage based on NSCache
 */
public class MemoryStorage: StorageAware {

  /// Domain prefix
  public static let prefix = "no.hyper.Cache.Memory"

  /// Storage root path
  public var path: String {
    return cache.name
  }

  /// Maximum size of the cache storage
  public var maxSize: UInt {
    didSet(value) {
      self.cache.totalCostLimit = Int(maxSize)
    }
  }

  /// Memory cache instance
  public let cache = NSCache()
  /// Queue for write operations
  public private(set) var writeQueue: dispatch_queue_t
  /// Queue for read operations
  public private(set) var readQueue: dispatch_queue_t

  // MARK: - Initialization

  /**
   Creates a new memory storage.

   - Parameter name: A name of the storage
   - Parameter maxSize: Maximum size of the cache storage
   */
  public required init(name: String, maxSize: UInt = 0) {
    self.maxSize = maxSize
    cache.name = "\(MemoryStorage.prefix).\(name.capitalizedString)"
    writeQueue = dispatch_queue_create("\(cache.name).WriteQueue", DISPATCH_QUEUE_SERIAL)
    readQueue = dispatch_queue_create("\(cache.name).ReadQueue", DISPATCH_QUEUE_SERIAL)
  }

  // MARK: - CacheAware

  /**
   Saves passed object in the memory.

   - Parameter key: Unique key to identify the object in the cache
   - Parameter object: Object that needs to be cached
   - Parameter expiry: Expiration date for the cached object
   - Parameter completion: Completion closure to be called when the task is done
   */
  public func add<T: Cachable>(key: String, object: T, expiry: Expiry = .Never, completion: (() -> Void)? = nil) {
    dispatch_async(writeQueue) { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      let capsule = Capsule(value: object, expiry: expiry)

      weakSelf.cache.setObject(capsule, forKey: key)
      completion?()
    }
  }

  /**
   Tries to retrieve the object from the memory storage.

   - Parameter key: Unique key to identify the object in the cache
   - Parameter completion: Completion closure returns object or nil
   */
  public func object<T: Cachable>(key: String, completion: (object: T?) -> Void) {
    dispatch_async(readQueue) { [weak self] in
      guard let weakSelf = self else {
        completion(object: nil)
        return
      }

      let capsule = weakSelf.cache.objectForKey(key) as? Capsule
      completion(object: capsule?.value as? T)

      if let capsule = capsule {
        weakSelf.removeIfExpired(key, capsule: capsule)
      }
    }
  }

  /**
   Removes the object from the cache by the given key.

   - Parameter key: Unique key to identify the object in the cache
   - Parameter completion: Completion closure to be called when the task is done
   */
  public func remove(key: String, completion: (() -> Void)? = nil) {
    dispatch_async(writeQueue) { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      weakSelf.cache.removeObjectForKey(key)
      completion?()
    }
  }

  /**
   Removes the object from the cache if it's expired.

   - Parameter key: Unique key to identify the object in the cache
   - Parameter completion: Completion closure to be called when the task is done
   */
  public func removeIfExpired(key: String, completion: (() -> Void)?) {
    dispatch_async(writeQueue) { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      if let capsule = weakSelf.cache.objectForKey(key) as? Capsule {
        weakSelf.removeIfExpired(key, capsule: capsule, completion: completion)
      } else {
        completion?()
      }
    }
  }

  /**
   Clears the cache storage.

   - Parameter completion: Completion closure to be called when the task is done
   */
  public func clear(completion: (() -> Void)? = nil) {
    dispatch_async(writeQueue) { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      weakSelf.cache.removeAllObjects()
      completion?()
    }
  }

  /**
   Clears all expired objects.

   - Parameter completion: Completion closure to be called when the task is done
   */
  public func clearExpired(completion: (() -> Void)? = nil) {
    clear(completion)
  }

  // MARK: - Helpers

  /**
   Removes the object from the cache if it's expired.

   - Parameter key: Unique key to identify the object in the cache
   - Parameter capsule: cached object wrapper
   - Parameter completion: Completion closure to be called when the task is done
   */
  func removeIfExpired(key: String, capsule: Capsule, completion: (() -> Void)? = nil) {
    if capsule.expired {
      remove(key, completion: completion)
    } else {
      completion?()
    }
  }
}
