import XCTest
@testable import Cache

final class HybridStorageTests: XCTestCase {
  private let cacheName = "WeirdoCache"
  private let key = "alongweirdkey"
  private let testObject = User(firstName: "John", lastName: "Targaryen")
  private var storage: HybridStorage<String, User>!
  private let fileManager = FileManager()

  override func setUp() {
    super.setUp()
    let memory = MemoryStorage<String, User>(config: MemoryConfig())
    let disk = try! DiskStorage<String, User>(config: DiskConfig(name: "HybridDisk"), transformer: TransformerFactory.forCodable(ofType: User.self))

    storage = HybridStorage(memoryStorage: memory, diskStorage: disk)
  }

  override func tearDown() {
    try? storage.removeAll()
    super.tearDown()
  }

  func testSetObject() throws {
    try when("set to storage") {
      try storage.setObject(testObject, forKey: key)
      let cachedObject = try storage.object(forKey: key)
      XCTAssertEqual(cachedObject, testObject)
    }

    try then("it is set to memory too") {
      let memoryObject = try storage.memoryStorage.object(forKey: key)
      XCTAssertNotNil(memoryObject)
    }

    try then("it is set to disk too") {
      let diskObject = try storage.diskStorage.object(forKey: key)
      XCTAssertNotNil(diskObject)
    }
  }

  func testEntry() throws {
    let expiryDate = Date()
    try storage.setObject(testObject, forKey: key, expiry: .date(expiryDate))
    let entry = try storage.entry(forKey: key)

    XCTAssertEqual(entry.object, testObject)
    XCTAssertEqual(entry.expiry.date, expiryDate)
  }

  /// Should resolve from disk and set in-memory cache if object not in-memory
  func testObjectCopyToMemory() throws {
    try when("set to disk only") {
      try storage.diskStorage.setObject(testObject, forKey: key)
      let cachedObject: User = try storage.object(forKey: key)
      XCTAssertEqual(cachedObject, testObject)
    }

    try then("there is no object in memory") {
      let inMemoryCachedObject = try storage.memoryStorage.object(forKey: key)
      XCTAssertEqual(inMemoryCachedObject, testObject)
    }
  }
  
  func testEntityExpiryForObjectCopyToMemory() throws {
    let date = Date().addingTimeInterval(3)
    try when("set to disk only") {
      try storage.diskStorage.setObject(testObject, forKey: key, expiry: .seconds(3))
      let entry = try storage.entry(forKey: key)
      //accuracy for slow disk processes
      XCTAssertEqual(entry.expiry.date.timeIntervalSinceReferenceDate,
                     date.timeIntervalSinceReferenceDate,
                     accuracy: 1.0)
    }
    
    try then("there is no object in memory") {
      let entry = try storage.memoryStorage.entry(forKey: key)
      //accuracy for slow disk processes
      XCTAssertEqual(entry.expiry.date.timeIntervalSinceReferenceDate,
                     date.timeIntervalSinceReferenceDate,
                     accuracy: 1.0)
    }
  }

  /// Removes cached object from memory and disk
  func testRemoveObject() throws {
    try given("set to storage") {
      try storage.setObject(testObject, forKey: key)
      XCTAssertNotNil(try storage.object(forKey: key))
    }

    try when("remove object from storage") {
      try storage.removeObject(forKey: key)
      let cachedObject = try? storage.object(forKey: key)
      XCTAssertNil(cachedObject)
    }

    then("there is no object in memory") {
      let memoryObject = try? storage.memoryStorage.object(forKey: key)
      XCTAssertNil(memoryObject)
    }

    then("there is no object on disk") {
      let diskObject = try? storage.diskStorage.object(forKey: key)
      XCTAssertNil(diskObject)
    }
  }

  /// Clears memory and disk cache
  func testClear() throws {
    try when("set and remove all") {
      try storage.setObject(testObject, forKey: key)
      try storage.removeAll()
      XCTAssertNil(try? storage.object(forKey: key))
    }

    then("there is no object in memory") {
      let memoryObject = try? storage.memoryStorage.object(forKey: key)
      XCTAssertNil(memoryObject)
    }

    then("there is no object on disk") {
      let diskObject = try? storage.diskStorage.object(forKey: key)
      XCTAssertNil(diskObject)
    }
  }

  func testDiskEmptyAfterClear() throws {
    try storage.setObject(testObject, forKey: key)
    try storage.removeAll()

    then("the disk directory is empty") {
      let contents = try? fileManager.contentsOfDirectory(atPath: storage.diskStorage.path)
      XCTAssertEqual(contents?.count, 0)
    }
  }

  /// Clears expired objects from memory and disk cache
  func testClearExpired() throws {
    let expiry1: Expiry = .date(Date().addingTimeInterval(-10))
    let expiry2: Expiry = .date(Date().addingTimeInterval(10))
    let key1 = "key1"
    let key2 = "key2"

    try when("save 2 objects with different keys and expiry") {
      try storage.setObject(testObject, forKey: key1, expiry: expiry1)
      try storage.setObject(testObject, forKey: key2, expiry: expiry2)
    }

    try when("remove expired objects") {
      try storage.removeExpiredObjects()
    }

    then("object with key2 survived") {
      XCTAssertNil(try? storage.object(forKey: key1))
      XCTAssertNotNil(try? storage.object(forKey: key2))
    }
  }

  // MARK: - Storage observers

  func testAddStorageObserver() throws {
    var changes = [StorageChange<String>]()
    storage.addStorageObserver(self) { _, _, change in
      changes.append(change)
    }

    try storage.setObject(testObject, forKey: "user1")
    XCTAssertEqual(changes, [StorageChange.add(key: "user1")])
    XCTAssertEqual(storage.storageObservations.count, 1)

    storage.addStorageObserver(self) { _, _, _ in }
    XCTAssertEqual(storage.storageObservations.count, 2)
  }

  func testRemoveStorageObserver() {
    let token = storage.addStorageObserver(self) { _, _, _ in }
    XCTAssertEqual(storage.storageObservations.count, 1)

    token.cancel()
    XCTAssertTrue(storage.storageObservations.isEmpty)
  }

  func testRemoveAllStorageObservers() {
    storage.addStorageObserver(self) { _, _, _ in }
    storage.addStorageObserver(self) { _, _, _ in }
    XCTAssertEqual(storage.storageObservations.count, 2)

    storage.removeAllStorageObservers()
    XCTAssertTrue(storage.storageObservations.isEmpty)
  }

  // MARK: - Key observers

  func testAddObserverForKey() throws {
    var changes = [KeyChange<User>]()
    storage.addObserver(self, forKey: "user1") { _, _, change in
      changes.append(change)
    }

    XCTAssertEqual(storage.keyObservations.count, 1)

    try storage.setObject(testObject, forKey: "user1")
    XCTAssertEqual(changes, [KeyChange.edit(before: nil, after: testObject)])

    storage.addObserver(self, forKey: "user1") { _, _, _ in }
    XCTAssertEqual(storage.keyObservations.count, 1)

    storage.addObserver(self, forKey: "user2") { _, _, _ in }
    XCTAssertEqual(storage.keyObservations.count, 2)
  }

  func testRemoveKeyObserver() {
    // Test remove for key
    storage.addObserver(self, forKey: "user1") { _, _, _ in }
    XCTAssertEqual(storage.keyObservations.count, 1)

    storage.removeObserver(forKey: "user1")
    XCTAssertTrue(storage.storageObservations.isEmpty)

    // Test remove by token
    let token = storage.addObserver(self, forKey: "user2") { _, _, _ in }
    XCTAssertEqual(storage.keyObservations.count, 1)

    token.cancel()
    XCTAssertTrue(storage.storageObservations.isEmpty)
  }

  func testRemoveAllKeyObservers() {
    storage.addObserver(self, forKey: "user1") { _, _, _ in }
    storage.addObserver(self, forKey: "user2") { _, _, _ in }
    XCTAssertEqual(storage.keyObservations.count, 2)

    storage.removeAllKeyObservers()
    XCTAssertTrue(storage.keyObservations.isEmpty)
  }
}
