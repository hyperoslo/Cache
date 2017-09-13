import XCTest
@testable import Cache

final class CapsuleTests: XCTestCase {
  let testObject = User(firstName: "a", lastName: "b")

  func testExpiredWhenNotExpired() {
    let date = Date(timeInterval: 100000, since: Date())
    let capsule = Capsule(value: testObject, expiry: .date(date))

    XCTAssertFalse(capsule.isExpired)
  }

  func testExpiredWhenExpired() {
    let date = Date(timeInterval: -100000, since: Date())
    let capsule = Capsule(value: testObject, expiry: .date(date))

    XCTAssertTrue(capsule.isExpired)
  }
}
