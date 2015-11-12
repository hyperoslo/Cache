import Foundation

class Capsule<T: Cachable>: NSObject {

  let value: T
  let expiryDate: NSDate

  var expired: Bool {
    return expiryDate.inThePast
  }

  // MARK: - Initialization

  init(value: T, expiry: Expiry) {
    self.value = value
    self.expiryDate = expiry.date
  }
}
