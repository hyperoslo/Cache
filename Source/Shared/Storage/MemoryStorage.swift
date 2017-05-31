import Foundation

/**
 Memory cache storage based on NSCache
 */
public final class MemoryStorage: StorageAware {
  /// Domain prefix
  public static let prefix = "no.hyper.Cache.Memory"
  /// Storage root path
  public var path: String {
    return cache.name
  }

  /// Maximum size of the cache storage
  public var maxSize: UInt
  /// Memory cache instance
  public let cache = NSCache<AnyObject, AnyObject>()
  /// Queue for write operations
  public fileprivate(set) var writeQueue: DispatchQueue
  /// Queue for read operations
  public fileprivate(set) var readQueue: DispatchQueue

  // MARK: - Initialization

  /**
   Creates a new memory storage.
   - Parameter name: A name of the storage
   - Parameter maxSize: Maximum size of the cache storage
   */
  public required init(name: String, maxSize: UInt = 0, cacheDirectory: String? = nil) {
    self.maxSize = maxSize
    cache.countLimit = Int(maxSize)
    cache.totalCostLimit = Int(maxSize)
    cache.name = "\(MemoryStorage.prefix).\(name.capitalized)"
    writeQueue = DispatchQueue(label: "\(cache.name).WriteQueue", attributes: [])
    readQueue = DispatchQueue(label: "\(cache.name).ReadQueue", attributes: [])
  }

  // MARK: - CacheAware

  /**
   Saves passed object in the memory.
   - Parameter key: Unique key to identify the object in the cache
   - Parameter object: Object that needs to be cached
   - Parameter expiry: Expiration date for the cached object
   - Parameter completion: Completion closure to be called when the task is done
   */
  public func add<T: Cachable>(_ key: String, object: T, expiry: Expiry = .never, completion: (() -> Void)? = nil) {
    writeQueue.async { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      let capsule = Capsule(value: object, expiry: expiry)

      weakSelf.cache.setObject(capsule, forKey: key as AnyObject)
      completion?()
    }
  }

  /**
   Tries to retrieve the object from the memory storage.
   - Parameter key: Unique key to identify the object in the cache
   - Parameter completion: Completion closure returns object or nil
   */
  public func object<T: Cachable>(_ key: String, completion: @escaping (_ object: T?) -> Void) {
    cacheEntry(key) { (entry: CacheEntry<T>?) in
      completion(entry?.object)
    }
  }

  /**
   Get cache entry which includes object with metadata.
   - Parameter key: Unique key to identify the object in the cache
   - Parameter completion: Completion closure returns object wrapper with metadata or nil
   */
  public func cacheEntry<T: Cachable>(_ key: String, completion: @escaping (_ object: CacheEntry<T>?) -> Void) {
    readQueue.async { [weak self] in
      guard let weakSelf = self else {
        completion(nil)
        return
      }
      guard let capsule = weakSelf.cache.object(forKey: key as AnyObject) as? Capsule else {
        completion(nil)
        return
      }

      var entry: CacheEntry<T>?
      if let object = capsule.object as? T {
        entry = CacheEntry(object: object, expiry: Expiry.date(capsule.expiryDate))
      }

      completion(entry)
      weakSelf.removeIfExpired(key, capsule: capsule)
    }
  }

  /**
   Removes the object from the cache by the given key.
   - Parameter key: Unique key to identify the object in the cache
   - Parameter completion: Completion closure to be called when the task is done
   */
  public func remove(_ key: String, completion: (() -> Void)? = nil) {
    writeQueue.async { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      weakSelf.cache.removeObject(forKey: key as AnyObject)
      completion?()
    }
  }

  /**
   Removes the object from the cache if it's expired.
   - Parameter key: Unique key to identify the object in the cache
   - Parameter completion: Completion closure to be called when the task is done
   */
  public func removeIfExpired(_ key: String, completion: (() -> Void)?) {
    writeQueue.async { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      if let capsule = weakSelf.cache.object(forKey: key as AnyObject) as? Capsule {
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
  public func clear(_ completion: (() -> Void)? = nil) {
    writeQueue.async { [weak self] in
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
  public func clearExpired(_ completion: (() -> Void)? = nil) {
    clear(completion)
  }

  // MARK: - Helpers

  /**
   Removes the object from the cache if it's expired.
   - Parameter key: Unique key to identify the object in the cache
   - Parameter capsule: cached object wrapper
   - Parameter completion: Completion closure to be called when the task is done
   */
  func removeIfExpired(_ key: String, capsule: Capsule, completion: (() -> Void)? = nil) {
    if capsule.expired {
      remove(key, completion: completion)
    } else {
      completion?()
    }
  }
}
