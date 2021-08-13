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
    
  func testAutoClearAllExpiredObjectWhenApplicationEnterBackground() {
      let expiry1: Expiry = .date(Date().addingTimeInterval(-10))
      let expiry2: Expiry = .date(Date().addingTimeInterval(10))
      let key1 = "item1"
      let key2 = "item2"
      var key1Removed = false
      var key2Removed = false
      storage.innerStorage.memoryStorage.onRemove = { key in
        key1Removed = true
        key2Removed = true
        XCTAssertTrue(key1Removed)
        XCTAssertTrue(key2Removed)
      }
          
      storage.innerStorage.diskStorage.onRemove = { path in
        key1Removed = true
        key2Removed = true
        XCTAssertTrue(key1Removed)
        XCTAssertTrue(key2Removed)
      }
      
      try? storage.setObject(user, forKey: key1, expiry: expiry1)
      try? storage.setObject(user, forKey: key2, expiry: expiry2)
      ///Device enters background
      NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
      
  func testManualManageExpirationMode() {
      storage.applyExpiratonMode(.manual)
      let expiry1: Expiry = .date(Date().addingTimeInterval(-10))
      let expiry2: Expiry = .date(Date().addingTimeInterval(60))
      let key1 = "item1"
      let key2 = "item2"
        
      var key1Removed = false
      var key2Removed = false
      storage.innerStorage.memoryStorage.onRemove = { key in
        key1Removed = true
        key2Removed = true
        XCTAssertFalse(key1Removed)
        XCTAssertFalse(key2Removed)
      }
        
      storage.innerStorage.diskStorage.onRemove = { path in
        key1Removed = true
        key2Removed = true
        XCTAssertFalse(key1Removed)
        XCTAssertFalse(key2Removed)
      }
      
      try? storage.setObject(user, forKey: key1, expiry: expiry1)
      try? storage.setObject(user, forKey: key2, expiry: expiry2)
      ///Device enters background
      NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

}
