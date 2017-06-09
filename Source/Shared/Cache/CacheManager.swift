#if os(macOS)
  import AppKit
#else
  import UIKit
#endif

// Completion with error
public typealias Completion = (Error?) -> Void

/**
 CacheManager supports storing all kinds of objects, as long as they conform to
 Cachable protocol. It's two layered cache (with front and back storages)
 */
class CacheManager: NSObject {
  enum CacheError: Error {
    case deallocated
    case notFound
  }
  /// Domain prefix
  static let prefix = "no.hyper.Cache"
  /// Cache configuration
  let config: Config
  /// Memory cache
  let frontStorage: MemoryStorage
  // Disk cache (used for content that outlives the application life-cycle)
  var backStorage: DiskStorage
  /// Queue for write operations
  fileprivate let writeQueue: DispatchQueue
  /// Queue for read operations
  fileprivate let readQueue: DispatchQueue

  // MARK: - Inititalization

  /**
   Creates a new instance of BasicHybridCache.
   - Parameter name: A name of the cache
   - Parameter config: Cache configuration
   */
  convenience init(name: String, config: Config = Config()) {
    let name = name
    let frontStorage = MemoryStorage(
      name: name,
      countLimit: config.memoryCountLimit,
      totalCostLimit: config.memoryTotalCostLimit
    )
    let backStorage = DiskStorage(
      name: name,
      maxSize: config.maxDiskSize,
      cacheDirectory: config.cacheDirectory
    )
    self.init(name: name, frontStorage: frontStorage, backStorage: backStorage, config: config)
  }

  /**
   Creates a new instance of BasicHybridCache.
   - Parameter name: A name of the cache
   - Parameter frontStorage: Memory cache instance
   - Parameter backStorage: Disk cache instance
   - Parameter config: Cache configuration
   */
  private init(name: String, frontStorage: MemoryStorage, backStorage: DiskStorage, config: Config) {
    self.frontStorage = frontStorage
    self.backStorage = backStorage
    self.config = config

    let queuePrefix = [CacheManager.prefix, name].joined(separator: ".")
    writeQueue = DispatchQueue(label: "\(queuePrefix).WriteQueue", attributes: [])
    readQueue = DispatchQueue(label: "\(queuePrefix).ReadQueue", attributes: [])

    super.init()
    let notificationCenter = NotificationCenter.default

    #if os(macOS)
      notificationCenter.addObserver(self, selector: #selector(clearExpiredDataInBackStorage),
                                     name: NSNotification.Name.NSApplicationWillTerminate, object: nil)
      notificationCenter.addObserver(self, selector: #selector(clearExpiredDataInBackStorage),
                                     name: NSNotification.Name.NSApplicationDidResignActive, object: nil)
    #else
      notificationCenter.addObserver(self, selector: #selector(clearExpiredDataInFrontStorage),
                                     name: .UIApplicationDidReceiveMemoryWarning, object: nil)
      notificationCenter.addObserver(self, selector: #selector(clearExpiredDataInBackStorage),
                                     name: .UIApplicationWillTerminate, object: nil)
      notificationCenter.addObserver(self, selector: #selector(CacheManager.applicationDidEnterBackground),
                                     name: .UIApplicationDidEnterBackground, object: nil)
    #endif

    // Clear expired cached objects.
    clearExpired(completion: nil)
  }

  /**
   Removes notification center observer.
   */
  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  #if !os(macOS)

  /**
   Clears expired cache items when the app enters background.
   */
  @objc private func applicationDidEnterBackground() {
    let application = UIApplication.shared
    var backgroundTask: UIBackgroundTaskIdentifier?

    backgroundTask = application.beginBackgroundTask (expirationHandler: { [weak self] in
      guard let backgroundTask = backgroundTask else {
        return
      }
      var mutableBackgroundTask = backgroundTask
      self?.endBackgroundTask(&mutableBackgroundTask)
    })

    writeQueue.async { [weak self] in
      guard let `self` = self, let backgroundTask = backgroundTask else {
        return
      }
      do {
        try self.backStorage.clearExpired()
      } catch {
        Logger.log(error: error)
      }
      var mutableBackgroundTask = backgroundTask

      DispatchQueue.main.async { [weak self] in
        self?.endBackgroundTask(&mutableBackgroundTask)
      }
    }
  }

  /**
   Ends given background task.
   - Parameter task: A UIBackgroundTaskIdentifier
   */
  private func endBackgroundTask(_ task: inout UIBackgroundTaskIdentifier) {
    UIApplication.shared.endBackgroundTask(task)
    task = UIBackgroundTaskInvalid
  }

  #endif

  /**
   Clears expired cache items in front cache.
   */
  @objc private func clearExpiredDataInFrontStorage() {
    writeQueue.async { [weak self] in
      self?.frontStorage.clearExpired()
    }
  }

  /**
   Clears expired cache items in back cache.
   */
  @objc private func clearExpiredDataInBackStorage() {
    writeQueue.async { [weak self] in
      do {
        try self?.backStorage.clearExpired()
      } catch {
        Logger.log(error: error)
      }
    }
  }
}

// MARK: - Async caching

extension CacheManager {
  /**
   Adds passed object to the front and back cache storages.
   - Parameter object: Object that needs to be cached
   - Parameter key: Unique key to identify the object in the cache
   - Parameter expiry: Expiration date for the cached object
   - Parameter completion: Completion closure to be called when the task is done
   */
  func addObject<T: Cachable>(_ object: T, forKey key: String, expiry: Expiry?, completion: Completion?) {
    let expiry = expiry ?? config.expiry
    writeQueue.async { [weak self] in
      do {
        guard let `self` = self else {
          throw CacheError.deallocated
        }
        self.frontStorage.addObject(object, forKey: key, expiry: expiry)
        try self.backStorage.addObject(object, forKey: key, expiry: expiry)
        completion?(nil)
      } catch {
        Logger.log(error: error)
        completion?(error)
      }
    }
  }

  /**
   Tries to retrieve the object from to the front and back cache storages.
   - Parameter key: Unique key to identify the object in the cache
   - Parameter completion: Completion closure to be called when the task is done
   */
  func object<T: Cachable>(forKey key: String, completion: @escaping (T?) -> Void) {
    cacheEntry(forKey: key) { (entry: CacheEntry<T>?) in
      completion(entry?.object)
    }
  }

  /**
   Tries to retrieve the cache entry from to the front and back cache storages.
   - Parameter key: Unique key to identify the cache entry in the cache
   - Parameter completion: Completion closure to be called when the task is done
   */
  func cacheEntry<T: Cachable>(forKey key: String, completion: @escaping (CacheEntry<T>?) -> Void) {
    readQueue.async { [weak self] in
      do {
        guard let `self` = self else {
          throw CacheError.notFound
        }
        if let entry: CacheEntry<T> = self.frontStorage.cacheEntry(forKey: key) {
          completion(entry)
          return
        }
        guard let entry: CacheEntry<T> = try self.backStorage.cacheEntry(forKey: key) else {
          throw CacheError.notFound
        }
        self.frontStorage.addObject(entry.object, forKey: key, expiry: entry.expiry)
        completion(entry)
      } catch {
        Logger.log(error: error)
        completion(nil)
      }
    }
  }

  /**
   Removes the object from to the front and back cache storages.
   - Parameter key: Unique key to identify the object in the cache
   - Parameter completion: Completion closure to be called when the task is done
   */
  func removeObject(forKey key: String, completion: Completion?) {
    writeQueue.async { [weak self] in
      do {
        guard let `self` = self else {
          throw CacheError.deallocated
        }
        self.frontStorage.removeObject(forKey: key)
        try self.backStorage.removeObject(forKey: key)
        completion?(nil)
      } catch {
        Logger.log(error: error)
        completion?(error)
      }
    }
  }

  /**
   Clears the front and back cache storages.
   - Parameter keepingRootDirectory: Pass `true` to keep the existing disk cache directory
   after removing its contents. The default value is `false`.
   - Parameter completion: Completion closure to be called when the task is done
   */
  func clear(keepingRootDirectory: Bool = false, completion: Completion?) {
    writeQueue.async { [weak self] in
      do {
        guard let `self` = self else {
          throw CacheError.deallocated
        }
        self.frontStorage.clear()
        try self.backStorage.clear()
        if keepingRootDirectory {
          try self.backStorage.createDirectory()
        }
        completion?(nil)
      } catch {
        Logger.log(error: error)
        completion?(error)
      }
    }
  }

  /**
   Clears all expired objects from front and back storages.
   - Parameter completion: Completion closure to be called when the task is done
   */
  func clearExpired(completion: Completion?) {
    writeQueue.async { [weak self] in
      do {
        guard let `self` = self else {
          throw CacheError.deallocated
        }
        self.frontStorage.clearExpired()
        try self.backStorage.clearExpired()
        completion?(nil)
      } catch {
        Logger.log(error: error)
        completion?(error)
      }
    }
  }
}

// MARK: - Sync caching

extension CacheManager {
  /**
    Calculates total disk cache size.
   */
  func totalDiskSize() throws -> UInt64 {
    var size: UInt64 = 0
    try readQueue.sync { [weak self] in
      size = try self?.backStorage.totalSize() ?? 0
    }
    return size
  }

  /**
   Adds passed object to the front and back cache storages.
   - Parameter object: Object that needs to be cached
   - Parameter key: Unique key to identify the object in the cache
   - Parameter expiry: Expiration date for the cached object
   */
  func addObject<T: Cachable>(_ object: T, forKey key: String, expiry: Expiry?) throws {
    let expiry = expiry ?? config.expiry
    try writeQueue.sync { [weak self] in
      self?.frontStorage.addObject(object, forKey: key, expiry: expiry)
      try self?.backStorage.addObject(object, forKey: key, expiry: expiry)
    }
  }

  /**
   Tries to retrieve the object from to the front and back cache storages.
   - Parameter key: Unique key to identify the object in the cache
   - Returns: Object from cache of nil
   */
  func object<T: Cachable>(forKey key: String) -> T? {
    return (cacheEntry(forKey: key) as CacheEntry<T>?)?.object
  }

  /**
   Tries to retrieve the cache entry from to the front and back cache storages.
   - Parameter key: Unique key to identify the cache entry in the cache
   - Returns: Object from cache of nil
   */
  func cacheEntry<T: Cachable>(forKey key: String) -> CacheEntry<T>? {
    var result: CacheEntry<T>?
    readQueue.sync { [weak self] in
      do {
        if let entry: CacheEntry<T> = self?.frontStorage.cacheEntry(forKey: key) {
          result = entry
          return
        }
        if let entry: CacheEntry<T> = try self?.backStorage.cacheEntry(forKey: key) {
          self?.frontStorage.addObject(entry.object, forKey: key, expiry: entry.expiry)
          result = entry
        }
      } catch {
        Logger.log(error: error)
      }
    }
    return result
  }

  /**
   Removes the object from to the front and back cache storages.
   - Parameter key: Unique key to identify the object in the cache
   */
  func removeObject(forKey key: String) throws {
    try writeQueue.sync { [weak self] in
      self?.frontStorage.removeObject(forKey: key)
      try self?.backStorage.removeObject(forKey: key)
    }
  }

  /**
   Clears the front and back cache storages.
   - Parameter keepingRootDirectory: Pass `true` to keep the existing disk cache directory
   after removing its contents. The default value is `false`.
   */
  func clear(keepingRootDirectory: Bool = false) throws {
    try writeQueue.sync { [weak self] in
      self?.frontStorage.clear()
      try self?.backStorage.clear()
      if keepingRootDirectory {
        try self?.backStorage.createDirectory()
      }
    }
  }

  /**
   Clears all expired objects from front and back storages.
   */
  func clearExpired() throws {
    try writeQueue.sync { [weak self] in
      self?.frontStorage.clearExpired()
      try self?.backStorage.clearExpired()
    }
  }
}
