import XCTest
@testable import Cache

final class JSONTests: XCTestCase {
  /// Test that it return a value
  func testObject() {
    XCTAssertTrue(JSON.array(["Floppy"]).object is [AnyObject])
    XCTAssertTrue(JSON.dictionary(["Key": "Value"]).object is [String: AnyObject])
  }
}
