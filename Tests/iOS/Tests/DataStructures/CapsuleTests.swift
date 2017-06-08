import XCTest
@testable import Cache

final class CapsuleTests: XCTestCase {
  func testExpiredWhenNotExpired() {
    let object = TestHelper.user
    let date = Date(timeInterval: 100000, since: Date())
    let capsule = Capsule(value: object, expiry: .date(date))

    XCTAssertFalse(capsule.isExpired)
  }

  func testExpiredWhenExpired() {
    let object = TestHelper.user
    let date = Date(timeInterval: -100000, since: Date())
    let capsule = Capsule(value: object, expiry: .date(date))

    XCTAssertTrue(capsule.isExpired)
  }
}
