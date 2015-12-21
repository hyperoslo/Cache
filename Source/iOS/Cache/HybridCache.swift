import UIKit

public class HybridCache: BasicHybridCache {

  // MARK: - Inititalization

  public override init(name: String, config: Config = Config.defaultConfig) {
    super.init(name: name, config: config)

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
