import Foundation

extension NSDate {

  var inThePast: Bool {
    return timeIntervalSinceNow < 0
  }
}