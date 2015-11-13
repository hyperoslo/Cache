import Foundation

public enum Expiry {
  case Never
  case Seconds(NSTimeInterval)
  case Date(NSDate)

  public var date: NSDate {
    let result: NSDate

    switch self {
    case .Never:
      result = NSDate.distantFuture()
    case .Seconds(let seconds):
      result = NSDate().dateByAddingTimeInterval(seconds)
    case .Date(let date):
      result = date
    }

    return result
  }
}