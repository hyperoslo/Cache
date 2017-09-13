import XCTest

extension XCTestCase {
  func given(_ description: String, closure: () throws -> Void) throws {
    try closure()
  }

  func when(_ description: String, closure: () throws -> Void) throws {
    try closure()
  }

  func then(_ description: String, closure: () throws -> Void) throws {
    try closure()
  }
}
