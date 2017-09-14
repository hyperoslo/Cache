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

extension XCTestCase {
  func wait(for duration: TimeInterval) {
    let waitExpectation = expectation(description: "Waiting")

    let when = DispatchTime.now() + duration
    DispatchQueue.main.asyncAfter(deadline: when) {
      waitExpectation.fulfill()
    }

    // We use a buffer here to avoid flakiness with Timer on CI
    waitForExpectations(timeout: duration + 0.5)
  }
}
