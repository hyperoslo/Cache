import XCTest
import SwiftHash
@testable import Cache

final class HybridStorageTests: XCTestCase {
  private let cacheName = "WeirdoCache"
  private let key = "alongweirdkey"
  private let testObject = User(firstName: "John", lastName: "Targaryen")
  private var storage: HybridStorage!
  private let fileManager = FileManager()

  override func setUp() {
    super.setUp()
    let memory = MemoryStorage(config: MemoryConfig())
    let disk = try! DiskStorage(config: DiskConfig(name: "Floppy"))

    storage = HybridStorage(memoryStorage: memory, diskStorage: disk)
  }

  override func tearDown() {
    try? storage.removeAll()
    super.tearDown()
  }

  func testSetObject() throws {
    try when("set to storage") {
      try storage.setObject(testObject, forKey: key)
      let cachedObject: User = try storage.object(forKey: key)
      XCTAssertEqual(cachedObject, testObject)
    }

    try then("it is set to memory too") {
      let memoryObject: User = try storage.memoryStorage.object(forKey: key)
      XCTAssertNotNil(memoryObject)
    }

    try then("it is set to disk too") {
      let diskObject: User = try storage.diskStorage.object(forKey: key)
      XCTAssertNotNil(diskObject)
    }
  }

  func testEntry() throws {
    let expiryDate = Date()
    try storage.setObject(testObject, forKey: key, expiry: .date(expiryDate))
    let entry: Entry<User> = try storage.entry(forKey: key)

    XCTAssertEqual(entry.object, testObject)
    XCTAssertEqual(entry.expiry.date, expiryDate)
  }

  /// Should resolve from disk and set in-memory cache if object not in-memory
  func testObjectCopyToMemory() throws {
    try when("set to disk only") {
      try storage.diskStorage.setObject(testObject, forKey: key)
      let cachedObject: User = try storage.object(forKey: key) as User
      XCTAssertEqual(cachedObject, testObject)
    }

    try then("there is no object in memory") {
      let inMemoryCachedObject = try storage.memoryStorage.object(forKey: key) as User
      XCTAssertEqual(inMemoryCachedObject, testObject)
    }
  }

  /// Removes cached object from memory and disk
  func testRemoveObject() throws {
    try given("set to storage") {
      try storage.setObject(testObject, forKey: key)
      XCTAssertNotNil(try storage.object(forKey: key) as User)
    }

    try when("remove object from storage") {
      try storage.removeObject(forKey: key)
      let cachedObject = try? storage.object(forKey: key) as User
      XCTAssertNil(cachedObject)
    }

    then("there is no object in memory") {
      let memoryObject = try? storage.memoryStorage.object(forKey: key) as User
      XCTAssertNil(memoryObject)
    }

    then("there is no object on disk") {
      let diskObject = try? storage.diskStorage.object(forKey: key) as User
      XCTAssertNil(diskObject)
    }
  }

  /// Clears memory and disk cache
  func testClear() throws {
    try when("set and remove all") {
      try storage.setObject(testObject, forKey: key)
      try storage.removeAll()
      XCTAssertNil(try? storage.object(forKey: key) as User)
    }

    then("there is no object in memory") {
      let memoryObject = try? storage.memoryStorage.object(forKey: key) as User
      XCTAssertNil(memoryObject)
    }

    then("there is no object on disk") {
      let diskObject = try? storage.diskStorage.object(forKey: key) as User
      XCTAssertNil(diskObject)
    }
  }

  func testDiskEmptyAfterClear() throws {
    try storage.setObject(testObject, forKey: key)
    try storage.removeAll()

    then("the disk directory is removed") {
      XCTAssertFalse(fileManager.fileExists(atPath: storage.diskStorage.path))
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
      XCTAssertNil(try? storage.object(forKey: key1) as User)
      XCTAssertNotNil(try? storage.object(forKey: key2) as User)
    }
  }
}
