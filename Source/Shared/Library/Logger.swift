import Foundation

// A message logger that prints errors when ever `Cache` is unable to perform its
// operation. Usually when ever a method throws. You can eanble `Logger` by setting
// `Logger.enabled` to `true`. However, if you don't want to debug using print statements
// you can capture errors by enabling `Swift Error break points`
public class Logger {
  // When `Logger` is enabled it will print `Cache` errors to the console.
  // It is disabled by default but you can always catch errors
  // using Swift Error break points even if the feature is
  // disabled.
  public static var isEnabled: Bool = false
  static func log(error: Error) {
    guard Logger.isEnabled else {
      return
    }

    NSLog("📦 Cache: \(error)")
  }
}
