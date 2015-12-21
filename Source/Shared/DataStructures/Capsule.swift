import Foundation

class Capsule: NSObject {

  let value: Any
  let expiryDate: NSDate

  var expired: Bool {
    return expiryDate.inThePast
  }

  // MARK: - Initialization

  init(value: Any, expiry: Expiry) {
    self.value = value
    self.expiryDate = expiry.date
  }
}
