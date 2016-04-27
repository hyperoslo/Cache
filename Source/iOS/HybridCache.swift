import UIKit

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

    let notificationCenter = NSNotificationCenter.defaultCenter()

    notificationCenter.addObserver(self, selector: #selector(HybridCache.applicationDidReceiveMemoryWarning),
      name: UIApplicationDidReceiveMemoryWarningNotification, object: nil)
    notificationCenter.addObserver(self, selector: #selector(HybridCache.applicationWillTerminate),
      name: UIApplicationWillTerminateNotification, object: nil)
    notificationCenter.addObserver(self, selector: #selector(HybridCache.applicationDidEnterBackground),
      name: UIApplicationDidEnterBackgroundNotification, object: nil)
  }

  /**
   Removes notification center observer.
   */
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
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
   Clears expired cache items when the app enters background.
   */
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

  /**
   Ends given background task.
   */
  func endBackgroundTask(inout task: UIBackgroundTaskIdentifier) {
    UIApplication.sharedApplication().endBackgroundTask(task)
    task = UIBackgroundTaskInvalid
  }
}
