import Foundation

// MARK: - Helpers

extension NSDate {

  var inThePast: Bool {
    return timeIntervalSinceNow < 0
  }
}
