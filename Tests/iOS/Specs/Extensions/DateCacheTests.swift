import XCTest
@testable import Cache

final class DateCacheTests: XCTestCase {
  /// Tests that it decodes from NSData
  func testDecode() {
    let date = Date()
    let data = NSKeyedArchiver.archivedData(withRootObject: date)
    let result = Date.decode(data)

    XCTAssertEqual(result, date)
  }

  /// Test that it encodes to NSData
  func testEncode() {
    let date = Date()
    let data = NSKeyedArchiver.archivedData(withRootObject: date)
    let result = data.encode()

    XCTAssertEqual(result, data)
  }

  func testInThePast() {
    var date = Date(timeInterval: 100000, since: Date())
    XCTAssertFalse(date.inThePast)

    date = Date(timeInterval: -100000, since: Date())
    XCTAssertTrue(date.inThePast)
  }
}
