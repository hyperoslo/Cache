import XCTest
@testable import Cache

final class DataCacheTests: XCTestCase {
  /// Tests that it decodes from NSData
  func testDecode() {
    let data = TestHelper.data(64)
    let result = Data.decode(data)

    XCTAssertEqual(result, data)
  }

  /// Test that it encodes to NSData
  func testEncode() {
    let data = TestHelper.data(64)
    let result = data.encode()

    XCTAssertEqual(result, data)
  }
}
