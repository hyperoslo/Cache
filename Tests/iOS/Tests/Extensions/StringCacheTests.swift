import XCTest
@testable import Cache

final class StringCacheTests: XCTestCase {
  /// Tests that it decodes from NSData
  func testDecode() {
    let string = self.name
    let data = string!.data(using: String.Encoding.utf8)!
    let result = String.decode(data)

    XCTAssertEqual(result, string)
  }

  /// Test that it encodes to NSData
  func testEncode() {
    let string = self.name
    let data = string!.data(using: String.Encoding.utf8)!
    let result = string!.encode()

    XCTAssertEqual(result, data)
  }
}
