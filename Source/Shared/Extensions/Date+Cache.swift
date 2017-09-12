import Foundation

/**
 Helper NSDate extension.
 */
extension Date {

  /// Checks if the date is in the past.
  var inThePast: Bool {
    return timeIntervalSinceNow < 0
  }
}
