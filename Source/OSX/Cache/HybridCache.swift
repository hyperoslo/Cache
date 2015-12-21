import UIKit

public class HybridCache: NSObject {

  public let name: String

  let config: Config
  let frontStorage: StorageAware
  var backStorage: StorageAware

  // MARK: - Inititalization

  public init(name: String, config: Config = Config.defaultConfig) {
    self.name = name
    self.config = config

    frontStorage = StorageFactory.resolve(name, kind: config.frontKind, maxSize: config.maxSize)
    backStorage = StorageFactory.resolve(name, kind: config.backKind, maxSize: config.maxSize)

    super.init()

    let notificationCenter = NSNotificationCenter.defaultCenter()

    notificationCenter.addObserver(self, selector: "applicationDidReceiveMemoryWarning",
      name: UIApplicationDidReceiveMemoryWarningNotification, object: nil)
    notificationCenter.addObserver(self, selector: "applicationWillTerminate",
      name: UIApplicationWillTerminateNotification, object: nil)
    notificationCenter.addObserver(self, selector: "applicationDidEnterBackground",
      name: UIApplicationDidEnterBackgroundNotification, object: nil)
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  // MARK: - Caching

  public func add<T: Cachable>(key: String, object: T, expiry: Expiry? = nil, completion: (() -> Void)? = nil) {
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

  public func object<T: Cachable>(key: String, completion: (object: T?) -> Void) {
    frontStorage.object(key) { [weak self] (object: T?) in
      if let object = object {
        completion(object: object)
        return
      }

      guard let weakSelf = self else {
        completion(object: object)
        return
      }

      weakSelf.backStorage.object(key) { (object: T?) in
        completion(object: object)
      }
    }
  }

  public func remove(key: String, completion: (() -> Void)? = nil) {
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

  public func clear(completion: (() -> Void)? = nil) {
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

  // MARK: - Notifications

  func applicationDidReceiveMemoryWarning() {
    frontStorage.clearExpired(nil)
  }

  func applicationWillTerminate() {
    backStorage.clearExpired(nil)
  }

  func applicationDidEnterBackground() {
    let application = UIApplication.sharedApplication()
    var backgroundTask: UIBackgroundTaskIdentifier?

    backgroundTask = application.beginBackgroundTaskWithExpirationHandler { [weak self] in
      guard let weakSelf = self, var backgroundTask = backgroundTask else { return }

      weakSelf.endBackgroundTask(&backgroundTask)
    }

    backStorage.clearExpired { [weak self] in
      guard let weakSelf = self, var backgroundTask = backgroundTask else { return }

      dispatch_async(dispatch_get_main_queue()) {
        weakSelf.endBackgroundTask(&backgroundTask)
      }
    }
  }

  func endBackgroundTask(inout task: UIBackgroundTaskIdentifier) {
    UIApplication.sharedApplication().endBackgroundTask(task)
    task = UIBackgroundTaskInvalid
  }
}
