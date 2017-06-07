import XCTest
@testable import Cache

final class UIImageCacheTests: XCTestCase {
  /// Tests that it decodes from NSData
  func testDecode() {
    let image = TestHelper.image()
    let data = image.encode()!
    let result = UIImage.decode(data)!

    XCTAssertTrue(result.isEqualToImage(image))
  }

  /// Test that it encodes to NSData
  func testEncode() {
    let image = TestHelper.image()
    let data = UIImagePNGRepresentation(image)
    let result = image.encode()!

    XCTAssertEqual(result, data)
  }
}
