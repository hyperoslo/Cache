import XCTest
@testable import Cache

final class ReadSyncWriteAsyncStorageTests: XCTestCase {
  private var storage: ReadSyncWriteAsyncStorage!
  let user = User(firstName: "John", lastName: "Snow")

  override func setUp() {
    super.setUp()
    let memory = MemoryStorage(config: MemoryConfig())
    let primitive = PrimitiveStorage(storage: memory)
    storage = ReadSyncWriteAsyncStorage(storage: primitive)
  }

  override func tearDown() {
    storage.removeAll(completion: { _ in })
    super.tearDown()
  }

  func testSetObject() throws {
    storage.setObject(user, forKey: "user", completion: { _ in })
    let cachedObject = try storage.object(forKey: "user") as User

    XCTAssertEqual(cachedObject, user)
  }

  func testRemoveAll() throws {
    given("add a lot of objects") {
      Array(0..<100).forEach {
        storage.setObject($0, forKey: "key-\($0)", completion: { _ in })
      }
    }

    when("remove all") {
      storage.removeAll(completion: { _ in })
    }

    try then("all are removed") {
      XCTAssertFalse(try storage.existsObject(ofType: Int.self, forKey: "key-99"))
    }
  }

  func testManyOperations() throws {
    let iterationCount = 10_000

    when("performs lots of operations") {
      DispatchQueue.concurrentPerform(iterations: iterationCount) { _ in
        do {
          var number = try storage.object(forKey: "number") as Int
          number += 1
          storage.setObject(number, forKey: "number", completion: { _ in })
        } catch {
          XCTFail(error.localizedDescription)
        }
      }
    }

    wait(for: 1)

    try then("all operation must complete") {
      let cachedObject = try storage.object(forKey: "number") as Int
      XCTAssertEqual(cachedObject, iterationCount)
    }
  }
}

