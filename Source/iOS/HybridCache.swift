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

    let notificationCenter = NotificationCenter.default

    notificationCenter.addObserver(self, selector: #selector(HybridCache.applicationDidReceiveMemoryWarning),
      name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil)
    notificationCenter.addObserver(self, selector: #selector(HybridCache.applicationWillTerminate),
      name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
    notificationCenter.addObserver(self, selector: #selector(HybridCache.applicationDidEnterBackground),
      name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
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
}
