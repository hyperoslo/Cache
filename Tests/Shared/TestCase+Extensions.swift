import XCTest

extension XCTestCase {
  func when(_ description: String, closure: () -> Void) {
    closure()
  }

  func then(_ description: String, closure: () -> Void) {
    closure()
  }
}
