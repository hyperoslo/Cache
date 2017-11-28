import XCTest
import Dispatch
@testable import Cache

final class SyncStorageTests: XCTestCase {
  private var storage: SyncStorage!
  let user = User(firstName: "John", lastName: "Snow")

  override func setUp() {
    super.setUp()
    let memory = MemoryStorage(config: MemoryConfig())
    let primitive = TypeWrapperStorage(storage: memory)
    storage = SyncStorage(storage: primitive, serialQueue: DispatchQueue(label: "Sync"))
  }

  override func tearDown() {
    try? storage.removeAll()
    super.tearDown()
  }

  func testSetObject() throws {
    try storage.setObject(user, forKey: "user")
    let cachedObject = try storage.object(ofType: User.self, forKey: "user")

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
}
