import XCTest
@testable import Cache

final class DateCacheTests: XCTestCase {
  func testInThePast() {
    var date = Date(timeInterval: 100000, since: Date())
    XCTAssertFalse(date.inThePast)

    date = Date(timeInterval: -100000, since: Date())
    XCTAssertTrue(date.inThePast)
  }
}
