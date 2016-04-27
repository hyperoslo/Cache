import Foundation

/**
 Helper enum to set the expiration date
 */
public enum Expiry {
  /// Object will be expired in the nearest future
  case Never
  /// Object will be expired in the specified amount of seconds
  case Seconds(NSTimeInterval)
  /// Object will be expired on the specified date
  case Date(NSDate)

  /// Returns the appropriate date object
  public var date: NSDate {
    let result: NSDate

    switch self {
    case .Never:
      // Ref: http://lists.apple.com/archives/cocoa-dev/2005/Apr/msg01833.html
      result = NSDate(timeIntervalSince1970: 60 * 60 * 24 * 365 * 68)
    case .Seconds(let seconds):
      result = NSDate().dateByAddingTimeInterval(seconds)
    case .Date(let date):
      result = date
    }

    return result
  }
}
