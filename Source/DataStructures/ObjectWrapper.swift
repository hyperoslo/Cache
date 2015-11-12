import Foundation

class ObjectWrapper<T>: NSObject {

  let value: T
  let expiryDate: NSDate

  var expired: Bool {
    return expiryDate.timeIntervalSinceNow < 0
  }

  // MARK: - Initialization

  init(value: T, expiry: Expiry) {
    self.value = value
    self.expiryDate = expiry.date
  }
}
