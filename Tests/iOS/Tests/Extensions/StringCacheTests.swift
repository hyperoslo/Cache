import XCTest
@testable import Cache

final class StringCacheTests: XCTestCase {
  /// Tests that it decodes from NSData
  func testDecode() {
    #if os(tvOS)
      let string = self.name!
    #else
      let string = self.name
    #endif

    let data = string.data(using: String.Encoding.utf8)!
    let result = String.decode(data)

    XCTAssertEqual(result, string)
  }

  /// Test that it encodes to NSData
  func testEncode() {
    #if os(tvOS)
      let string = self.name!
    #else
      let string = self.name
    #endif

    let data = string.data(using: String.Encoding.utf8)!
    let result = string.encode()

    XCTAssertEqual(result, data)
  }
}
