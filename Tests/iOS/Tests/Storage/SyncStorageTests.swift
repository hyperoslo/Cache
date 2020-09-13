import XCTest
import Dispatch
@testable import Cache

final class SyncStorageTests: XCTestCase {
  private var storage: SyncStorage<String, User>!
  let user = User(firstName: "John", lastName: "Snow")

  override func setUp() {
    super.setUp()

    let memory = MemoryStorage<String, User>(config: MemoryConfig())
    let disk = try! DiskStorage<String, User>(config: DiskConfig(name: "HybridDisk"), transformer: TransformerFactory.forCodable(ofType: User.self))

    let hybridStorage = HybridStorage(memoryStorage: memory, diskStorage: disk)
    storage = SyncStorage(storage: hybridStorage, serialQueue: DispatchQueue(label: "Sync"))
  }

  override func tearDown() {
    try? storage.removeAll()
    super.tearDown()
  }

  func testSetObject() throws {
    try storage.setObject(user, forKey: "user")
    let cachedObject = try storage.object(forKey: "user")

    XCTAssertEqual(cachedObject, user)
  }

  func testRemoveAll() throws {
    let intStorage = storage.transform(transformer: TransformerFactory.forCodable(ofType: Int.self))
    try given("add a lot of objects") {
      try Array(0..<100).forEach {
        try intStorage.setObject($0, forKey: "key-\($0)")
      }
    }

    try when("remove all") {
      try intStorage.removeAll()
    }

    try then("all are removed") {
      XCTAssertFalse(try intStorage.existsObject(forKey: "key-99"))
    }
  }
}
