import Foundation

struct TestHelper {
  static var user: User {
    return User(firstName: "John", lastName: "Snow")
  }

  static func data(_ length : Int) -> Data {
    let buffer = [UInt8](repeating: 0, count: length)
    return Data(bytes: buffer)
  }

  static func triggerApplicationEvents() {
    #if !os(macOS)
      NotificationCenter.default.post(name: .UIApplicationDidEnterBackground, object: nil)
      NotificationCenter.default.post(name: .UIApplicationWillTerminate, object: nil)
    #else
      NotificationCenter.default.post(name: NSNotification.Name.NSApplicationWillTerminate, object: nil)
      NotificationCenter.default.post(name: NSNotification.Name.NSApplicationDidResignActive, object: nil)
    #endif
  }
}
