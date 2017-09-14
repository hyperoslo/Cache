import XCTest
@testable import Cache

final class MemoryCapsuleTests: XCTestCase {
  let testObject = User(firstName: "a", lastName: "b")

  func testExpiredWhenNotExpired() {
    let date = Date(timeInterval: 100000, since: Date())
    let capsule = MemoryCapsule(value: testObject, expiry: .date(date))

    XCTAssertFalse(capsule.expiry.isExpired)
  }

  func testExpiredWhenExpired() {
    let date = Date(timeInterval: -100000, since: Date())
    let capsule = MemoryCapsule(value: testObject, expiry: .date(date))

    XCTAssertTrue(capsule.expiry.isExpired)
  }
}
