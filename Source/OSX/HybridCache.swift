import Cocoa

public class HybridCache: BasicHybridCache {

  // MARK: - Inititalization

  public override init(name: String, config: Config = Config.defaultConfig) {
    super.init(name: name, config: config)

    let notificationCenter = NSNotificationCenter.defaultCenter()

    notificationCenter.addObserver(self, selector: "applicationWillTerminate",
      name: NSApplicationWillTerminateNotification, object: nil)
    notificationCenter.addObserver(self, selector: "applicationDidResignActive",
      name: NSApplicationDidResignActiveNotification, object: nil)
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

  func applicationDidResignActive() {
    backStorage.clearExpired(nil)
  }
}
