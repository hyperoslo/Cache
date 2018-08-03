import XCTest
@testable import Cache

final class ObservationTokenTests: XCTestCase {
  func testCancel() {
    var cancelled = false

    let token = ObservationToken {
      cancelled = true
    }

    token.cancel()
    XCTAssertTrue(cancelled)
  }
}
