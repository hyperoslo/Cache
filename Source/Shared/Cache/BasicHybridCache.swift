#if os(macOS)
  import AppKit
#else
  import UIKit
#endif

/**
 BasicHybridCache supports storing all kinds of objects, as long as they conform to
 Cachable protocol. It's two layered cache (with front and back storages)
 */
public class BasicHybridCache: NSObject {
  enum CacheError: Error {
    case deallocated
    case notFound
  }
  /// Domain prefix
  static let prefix = "no.hyper.Cache"
  /// A name of the cache
  public let name: String
  /// Cache configuration
  let config: Config
  /// Memory cache
  let frontStorage: MemoryStorage
  // Disk cache (used for content that outlives the application life-cycle)
  var backStorage: DiskStorage
  /// Queue for write operations
  private(set) var writeQueue: DispatchQueue
  /// Queue for read operations
  private(set) var readQueue: DispatchQueue
  // Disk storage path
  public var path: String {
    return backStorage.path
  }

  // MARK: - Inititalization

  /**
   Creates a new instance of BasicHybridCache.
   - Parameter name: A name of the cache
   - Parameter config: Cache configuration
   */
  public convenience init(name: String, config: Config = Config()) {
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
  init(name: String, frontStorage: MemoryStorage, backStorage: DiskStorage, config: Config) {
    self.name = name
    self.frontStorage = frontStorage
    self.backStorage = backStorage
    self.config = config

    let queuePrefix = [BasicHybridCache.prefix, name].joined(separator: ".")
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
      notificationCenter.addObserver(self, selector: #selector(HybridCache.applicationDidEnterBackground),
                                     name: .UIApplicationDidEnterBackground, object: nil)
    #endif
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

// MARK: - Data protection

public extension BasicHybridCache {
  #if os(iOS) || os(tvOS)
  /// Data protection is used to store files in an encrypted format on disk and to decrypt them on demand
  func setFileProtection( _ type: FileProtectionType) throws {
    try backStorage.setFileProtection(type)
  }
  #endif

  /// Set attributes on the disk cache folder.
  func setDiskCacheDirectoryAttributes(_ attributes: [FileAttributeKey : Any]) throws {
    try backStorage.setDirectoryAttributes(attributes)
  }
}

// MARK: - Async caching

extension BasicHybridCache {
  public typealias Completion = (Error?) -> Void
  /**
   Adds passed object to the front and back cache storages.
   - Parameter object: Object that needs to be cached
   - Parameter key: Unique key to identify the object in the cache
   - Parameter expiry: Expiration date for the cached object
   - Parameter completion: Completion closure to be called when the task is done
   */
  func add<T: Cachable>(_ object: T, forKey key: String, expiry: Expiry?, completion: Completion? = nil) {
    let expiry = expiry ?? config.expiry
    writeQueue.async { [weak self] in
      do {
        guard let `self` = self else {
          throw CacheError.deallocated
        }
        self.frontStorage.add(key, object: object, expiry: expiry)
        try self.backStorage.add(key, object: object, expiry: expiry)
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
    cacheEntry(forKey: key) { entry in
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
        if let entry: CacheEntry<T> = self.frontStorage.cacheEntry(key) {
          completion(entry)
          return
        }
        guard let entry: CacheEntry<T> = try self.backStorage.cacheEntry(key) else {
          throw CacheError.notFound
        }
        self.frontStorage.add(key, object: entry.object, expiry: entry.expiry)
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
  public func remove(_ key: String, completion: Completion? = nil) {
    writeQueue.async { [weak self] in
      do {
        guard let `self` = self else {
          throw CacheError.deallocated
        }
        self.frontStorage.remove(key)
        try self.backStorage.remove(key)
        completion?(nil)
      } catch {
        Logger.log(error: error)
        completion?(error)
      }
    }
  }

  /**
   Clears the front and back cache storages.
   - Parameter completion: Completion closure to be called when the task is done
   */
  public func clear(completion: Completion? = nil) {
    writeQueue.async { [weak self] in
      do {
        guard let `self` = self else {
          throw CacheError.deallocated
        }
        self.frontStorage.clear()
        try self.backStorage.clear()
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
  public func clearExpired(completion: Completion? = nil) {
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
