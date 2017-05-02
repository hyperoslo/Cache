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

  /// A name of the cache
  public let name: String

  /// Cache configuration
  let config: Config
  /// Front cache (should be less time and memory consuming)
  let frontStorage: StorageAware
  // BAck cache (used for content that outlives the application life-cycle)
  var backStorage: StorageAware

  public var path: String {
    return backStorage.path
  }

  // MARK: - Inititalization

  /**
   Creates a new instance of BasicHybridCache.

   - Parameter name: A name of the cache
   - Parameter config: Cache configuration
   */
  public init(name: String, config: Config = Config.defaultConfig) {
    self.name = name
    self.config = config

    frontStorage = StorageFactory.resolve(name, kind: config.frontKind, maxSize: UInt(config.maxObjects))
    backStorage = StorageFactory.resolve(name, kind: config.backKind, maxSize: config.maxSize)
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

  // MARK: - Caching

  /**
   Adds passed object to the front and back cache storages.

   - Parameter object: Object that needs to be cached
   - Parameter key: Unique key to identify the object in the cache
   - Parameter expiry: Expiration date for the cached object
   - Parameter completion: Completion closure to be called when the task is done
   */
  func add<T: Cachable>(_ object: T, forKey key: String,
           expiry: Expiry? = nil, completion: (() -> Void)? = nil) {
    let expiry = expiry ?? config.expiry

    frontStorage.add(key, object: object, expiry: expiry) { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      weakSelf.backStorage.add(key, object: object, expiry: expiry) {
        completion?()
      }
    }
  }

  /**
   Tries to retrieve the object from to the front and back cache storages.

   - Parameter key: Unique key to identify the object in the cache
   - Parameter completion: Completion closure returns object or nil
   */
  func object<T: Cachable>(forKey key: String, completion: @escaping (_ object: T?) -> Void) {
    frontStorage.object(key) { [weak self] (object: T?) in
      if let object = object {
        completion(object)
        return
      }

      guard let weakSelf = self else {
        completion(object)
        return
      }

      weakSelf.backStorage.object(key) { (object: T?) in
        completion(object)
      }
    }
  }

  /**
   Removes the object from to the front and back cache storages.

   - Parameter key: Unique key to identify the object in the cache
   - Parameter completion: Completion closure to be called when the task is done
   */
  public func remove(_ key: String, completion: (() -> Void)? = nil) {
    frontStorage.remove(key) { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      weakSelf.backStorage.remove(key) {
        completion?()
      }
    }
  }

  /**
   Clears the front and back cache storages.

   - Parameter completion: Completion closure to be called when the task is done
   */
  public func clear(_ completion: (() -> Void)? = nil) {
    frontStorage.clear() { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      weakSelf.backStorage.clear() {
        completion?()
      }
    }
  }

  /**
   Clears all expired objects from front and back storages.

   - Parameter completion: Completion closure to be called when the task is done
   */
  public func clearExpired(_ completion: (() -> Void)? = nil) {
    frontStorage.clearExpired { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      weakSelf.backStorage.clearExpired() {
        completion?()
      }
    }
  }

  /**
   Clears expired cache items in front cache.
   */
  func clearExpiredDataInFrontStorage() {
    frontStorage.clearExpired(nil)
  }

  /**
   Clears expired cache items in back cache.
   */
  func clearExpiredDataInBackStorage() {
    backStorage.clearExpired(nil)
  }

  #if !os(macOS)

  /**
   Clears expired cache items when the app enters background.
   */
  func applicationDidEnterBackground() {
    let application = UIApplication.shared
    var backgroundTask: UIBackgroundTaskIdentifier?

    backgroundTask = application.beginBackgroundTask (expirationHandler: { [weak self] in
      guard let weakSelf = self, let backgroundTask = backgroundTask else { return }
      var mutableBackgroundTask = backgroundTask

      weakSelf.endBackgroundTask(&mutableBackgroundTask)
    })

    backStorage.clearExpired { [weak self] in
      guard let weakSelf = self, let backgroundTask = backgroundTask else { return }
      var mutableBackgroundTask = backgroundTask

      DispatchQueue.main.async {
        weakSelf.endBackgroundTask(&mutableBackgroundTask)
      }
    }
  }

  /**
   Ends given background task.
   - Parameter task: A UIBackgroundTaskIdentifier
   */
  func endBackgroundTask(_ task: inout UIBackgroundTaskIdentifier) {
    UIApplication.shared.endBackgroundTask(task)
    task = UIBackgroundTaskInvalid
  }

  #endif
}
