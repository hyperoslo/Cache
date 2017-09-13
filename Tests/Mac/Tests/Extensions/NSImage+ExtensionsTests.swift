import XCTest
@testable import Cache

final class NSImageCacheTests: XCTestCase {
  /// Tests that it decodes from NSData
  func testDecode() {
    let image = TestHelper.image()
    let data = image.encode()!
    let result = NSImage.decode(data)!

    XCTAssertTrue(result.isEqualToImage(image))
  }

  /// Test that it encodes to NSData
  func testEncode() {
    let image = TestHelper.image()
    let representation = image.tiffRepresentation!
    let imageFileType: NSBitmapImageRep.FileType = .png
    let data = NSBitmapImageRep(data: representation)!
      .representation(using: imageFileType, properties: [:])
    let result = image.encode()!

    XCTAssertEqual(result, data)
  }
}
