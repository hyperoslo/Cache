import Foundation

public enum Expiry {
  case Never
  case Seconds(NSTimeInterval)
  case Date(NSDate)

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
