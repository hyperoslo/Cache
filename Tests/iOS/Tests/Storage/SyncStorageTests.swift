import XCTest
import Dispatch
@testable import Cache

final class SyncStorageTests: XCTestCase {
  private var storage: SyncStorage<User>!
  let user = User(firstName: "John", lastName: "Snow")
  let userTwo = User(firstName: "Job", lastName: "Thatcher")

  override func setUp() {
    super.setUp()
    createStorage(autoRemoveOn: false)
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
  
  func testGetObjects() throws {
    try storage.setObject(user, forKey: "john")
    try storage.setObject(userTwo, forKey: "job")
    
    let objects = try storage.objects()
    XCTAssertEqual(objects.count, 2)
    XCTAssertTrue(objects.contains(userTwo))
    XCTAssertTrue(objects.contains(user))
  }
  
  func testGetObjects_EmptyEntries() throws {
    let objects = try storage.objects()
    XCTAssertEqual(objects.count, 0)
  }

  func testAutoRemove() throws {
    let date = Date().addingTimeInterval(-120)
    createStorage(autoRemoveOn: true)

    try storage.setObject(user, forKey: user.firstName, expiry: .date(date))
    do {
      _ = try storage.object(forKey: user.firstName)
    } catch {
      XCTAssertTrue(error is StorageError)
      XCTAssertEqual(error as! StorageError, StorageError.hasExpired)
    }
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

  fileprivate func createStorage(autoRemoveOn: Bool) {
    let memory = MemoryStorage<User>(config: MemoryConfig())
    let disk = try! DiskStorage<User>(config: DiskConfig(name: "HybridDisk"), transformer: TransformerFactory.forCodable(ofType: User.self))

    let hybridStorage = HybridStorage(memoryStorage: memory, diskStorage: disk)
    storage = SyncStorage(storage: hybridStorage, serialQueue: DispatchQueue(label: "Sync"), autoRemove: autoRemoveOn)
  }
}
