import XCTest
@testable import Cache

final class SyncStorageTests: XCTestCase {
  private var storage: SyncStorage!
  let user = User(firstName: "John", lastName: "Snow")

  override func setUp() {
    super.setUp()
    let memory = MemoryStorage(config: MemoryConfig())
    let primitive = PrimitiveStorage(storage: memory)
    storage = SyncStorage(storage: primitive)
  }

  override func tearDown() {
    try? storage.removeAll()
    super.tearDown()
  }

  func testSetObject() throws {
    try storage.setObject(user, forKey: "user")
    let cachedObject = try storage.object(forKey: "user") as User

    XCTAssertEqual(cachedObject, user)
  }

  func testRemoveAll() throws {
    try given("add a lot of objects") {
      try Array(0..<100).forEach {
        try storage.setObject($0, forKey: "key-\($0)")
      }
    }

    try when("remove all") {
      try storage.removeAll()
    }

    try then("all are removed") {
      XCTAssertFalse(try storage.existsObject(ofType: Int.self, forKey: "key-99"))
    }
  }

  func testManyOperations() throws {
    let iterationCount = 1_000

    try given("seed initial value") {
      try storage.setObject(0, forKey: "number")
    }

    when("performs lots of operations") {
      DispatchQueue.concurrentPerform(iterations: iterationCount) { _ in
        do {
          var number = try storage.object(forKey: "number") as Int
          number += 1
          try storage.setObject(number, forKey: "number")
        } catch {
          XCTFail(error.localizedDescription)
        }
      }
    }

    do {
      try then("all operation must complete") {
        let number = try storage.object(forKey: "number") as Int
        XCTAssertEqual(number, iterationCount)
      }
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
}
