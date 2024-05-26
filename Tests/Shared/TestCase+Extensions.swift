import XCTest

extension XCTestCase {
  func given(_ description: String, closure: () throws -> Void) rethrows {
    try closure()
  }

  func given(_ description: String, closure: () async throws -> Void) async rethrows {
    try await closure()
  }

  func when(_ description: String, closure: () throws -> Void) rethrows {
    try closure()
  }

  func when(_ description: String, closure: () async throws -> Void) async rethrows {
    try await closure()
  }

  func then(_ description: String, closure: () throws -> Void) rethrows {
    try closure()
  }

  func then(_ description: String, closure: () async throws -> Void) async rethrows {
    try await closure()
  }
}
