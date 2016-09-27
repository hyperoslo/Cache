import Cocoa

/**
 HybridCache supports storing all kinds of objects, as long as they conform to
 Cachable protocol. It's two layered cache (with front and back storages), as well as Cache.
 Subscribes to system notifications to clear expired cached objects.
 */
public class HybridCache: BasicHybridCache {

  // MARK: - Inititalization

  /**
   Creates a new instance of BasicHybridCache and subscribes to system notifications.

   - Parameter name: A name of the cache
   - Parameter config: Cache configuration
   */
  public override init(name: String, config: Config = Config.defaultConfig) {
    super.init(name: name, config: config)

    let notificationCenter = NotificationCenter.default

    notificationCenter.addObserver(self, selector: #selector(HybridCache.applicationWillTerminate),
      name: NSNotification.Name.NSApplicationWillTerminate, object: nil)
    notificationCenter.addObserver(self, selector: #selector(HybridCache.applicationDidResignActive),
      name: NSNotification.Name.NSApplicationDidResignActive, object: nil)
  }

  /**
   Removes notification center observer.
   */
  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  // MARK: - Notifications

  /**
   Clears expired cache items when the app recieves memory warning.
   */
  func applicationDidReceiveMemoryWarning() {
    frontStorage.clearExpired(nil)
  }

  /**
   Clears expired cache items when the app terminates.
   */
  func applicationWillTerminate() {
    backStorage.clearExpired(nil)
  }

  /**
   Clears expired cache items when the app resign active.
   */
  func applicationDidResignActive() {
    backStorage.clearExpired(nil)
  }
}
