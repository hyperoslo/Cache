import XCTest
@testable import Cache

final class ImageWrapperTests: XCTestCase {
  func testImage() {
    let image = TestHelper.image(size: CGSize(width: 100, height: 100))
    let wrapper = ImageWrapper(image: image)

    let data = try! JSONEncoder().encode(wrapper)
    let anotherWrapper = try! JSONDecoder().decode(ImageWrapper.self, from: data)

    XCTAssertTrue(image.isEqualToImage(anotherWrapper.image))
  }
}
