import XCTest
@testable import Cache

final class JSONCacheTests: XCTestCase {
  /// Test that it decodes a dictionary from NSData
  func testDecodeWithDictionary() {
    let object = ["key": "value"]
    let data = try! JSONSerialization.data(
      withJSONObject: object,
      options: JSONSerialization.WritingOptions()
    )
    let result = JSON.decode(data)!

    switch result {
    case JSON.dictionary(let dictionary):
      XCTAssertTrue(dictionary["key"] is String)
      XCTAssertEqual(dictionary["key"] as? String, object["key"])
    default:
      break
    }
  }

  /// Test that it decodes an array from NSData
  func testDecodeWithArray() {
    let object = ["value1", "value2", "value3"]
    let data = try! JSONSerialization.data(
      withJSONObject: object,
      options: JSONSerialization.WritingOptions()
    )
    let result = JSON.decode(data)!

    switch result {
    case JSON.array(let array):
      XCTAssertTrue(array is [String])
      XCTAssertEqual(array.count, 3)
      XCTAssertEqual(array[0] as? String, object[0])
    default:
      break
    }
  }

  /// Test that it encodes a dictionary to NSData
  func testEncodeWithDictionary() {
    let object = ["key": "value"]
    let data = try! JSONSerialization.data(
      withJSONObject: object,
      options: JSONSerialization.WritingOptions()
    )
    let result = JSON.dictionary(object as [String : AnyObject]).encode()

    XCTAssertEqual(result, data)
  }

  /// Test that it encodes an array to NSData
  func testEncodeWithArray() {
    let object = ["value1", "value2", "value3"]
    let data = try! JSONSerialization.data(
      withJSONObject: object,
      options: JSONSerialization.WritingOptions()
    )
    let result = JSON.array(object as [AnyObject]).encode()

    XCTAssertEqual(result, data)
  }
}
