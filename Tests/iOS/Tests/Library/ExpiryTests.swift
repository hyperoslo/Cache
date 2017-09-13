import XCTest
@testable import Cache

final class ExpiryTests: XCTestCase {
  /// Tests that it returns date in the distant future
  func testNever() {
    let date = Date(timeIntervalSince1970: 60 * 60 * 24 * 365 * 68)
    let expiry = Expiry.never

    XCTAssertEqual(expiry.date, date)
  }

  /// Tests that it returns date by adding time interval
  func testSeconds() {
    let date = Date().addingTimeInterval(1000)
    let expiry = Expiry.seconds(1000)

    XCTAssertEqual(
      expiry.date.timeIntervalSinceReferenceDate,
      date.timeIntervalSinceReferenceDate,
      accuracy: 0.1
    )
  }

  /// Tests that it returns a specified date
  func testDate() {
    let date = Date().addingTimeInterval(1000)
    let expiry = Expiry.date(date)

    XCTAssertEqual(expiry.date, date)
  }
}
