import XCTest
@testable import Cache

final class HasherConstantAccrossExecutionsTests: XCTestCase {
  func testHashValueRemainsTheSameAsLastTime() {
    // Warning: this test may start failing after a Swift Update
    let value = "some string with some values"
    var hasher = Hasher.constantAccrossExecutions()
    value.hash(into: &hasher)
    XCTAssertEqual(hasher.finalize(), -4706942985426845298)
  }
}
