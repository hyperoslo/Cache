import XCTest

extension XCTestCase {
  func given(_ description: String, closure: () throws -> Void) rethrows {
    try closure()
  }

  func when(_ description: String, closure: () throws -> Void) rethrows {
    try closure()
  }

  func then(_ description: String, closure: () throws -> Void) rethrows {
    try closure()
  }
}
