import XCTest
@testable import Cache

extension NSDictionary: Cachable {}

final class NSDictionaryCacheTests: XCTestCase {
  /// Tests that it decodes from NSData
  func testDecode() {
    let dictionary = NSDictionary(dictionary: ["key": "value"])
    let data = NSKeyedArchiver.archivedData(withRootObject: dictionary)
    let result = NSDictionary.decode(data)

    XCTAssertEqual(result, dictionary)
  }

  /// Test that it encodes to NSData
  func testEncode() {
    let dictionary = NSDictionary(dictionary: ["key": "value"])
    let data = NSKeyedArchiver.archivedData(withRootObject: dictionary)
    let result = data.encode()

    XCTAssertEqual(result, data)
  }
}
