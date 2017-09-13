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
    try! storage.removeAll()
    super.tearDown()
  }

  func testSetObject() throws {
    try storage.setObject(testObject, forKey: key)
    let cachedObject: User = try storage.object(forKey: key)
    XCTAssertEqual(cachedObject, testObject)

    let memoryObject: User = try storage.memoryStorage.object(forKey: key)
    XCTAssertNotNil(memoryObject)

    let diskObject: User = try storage.diskStorage.object(forKey: key)
    XCTAssertNotNil(diskObject)
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
    try storage.diskStorage.setObject(testObject, forKey: key)
    let cachedObject: User = try storage.object(forKey: key) as User
    XCTAssertEqual(cachedObject, testObject)

    let inMemoryCachedObject = try storage.memoryStorage.object(forKey: key) as User
    XCTAssertEqual(inMemoryCachedObject, testObject)
  }

  /// Removes cached object from memory and disk
  func testRemoveObject() throws {
    try storage.setObject(object, forKey: key)
    XCTAssertNotNil(storage.object(forKey: key) as String?)

    try storage.removeObject(forKey: key)
    XCTAssertNil(storage.object(forKey: key) as String?)

    let memoryObject: String? = self.storage.manager.frontStorage.object(forKey: self.key)
    XCTAssertNil(memoryObject)

    var diskObject: String?
    do {
      diskObject = try self.storage.manager.backStorage.object(forKey: self.key)
    } catch {}

    XCTAssertNil(diskObject)
  }

  /*

  /// Clears memory and disk cache
  func testClear() throws {
    try storage.addObject(object, forKey: key)
    try storage.clear()
    XCTAssertNil(storage.object(forKey: key) as String?)

    let memoryObject: String? = self.storage.manager.frontStorage.object(forKey: self.key)
    XCTAssertNil(memoryObject)

    var diskObject: String?
    do {
      diskObject = try self.storage.manager.backStorage.object(forKey: self.key)
    } catch {}
    XCTAssertNil(diskObject)
  }

  /// Test that it clears cached files, but keeps root directory
  func testClearKeepingRootDirectory() throws {
    try storage.addObject(object, forKey: key)
    try storage.clear(keepingRootDirectory: true)
    XCTAssertNil(storage.object(forKey: key) as String?)
    XCTAssertTrue(fileManager.fileExists(atPath: storage.manager.backStorage.path))
  }

  /// Clears expired objects from memory and disk cache
  func testClearExpired() throws {
    let expiry1: Expiry = .date(Date().addingTimeInterval(-100000))
    let expiry2: Expiry = .date(Date().addingTimeInterval(100000))
    let key1 = "key1"
    let key2 = "key2"

    try storage.addObject(object, forKey: key1, expiry: expiry1)
    try storage.addObject(object, forKey: key2, expiry: expiry2)
    try storage.clearExpired()
    XCTAssertNil(storage.object(forKey: key1) as String?)
    XCTAssertNotNil(storage.object(forKey: key2) as String?)
  }

  func testTotalDiskSize() throws {
    let cache = SpecializedCache<Data>(name: cacheName)
    try storage.addObject(TestHelper.data(10), forKey: "key1")
    try storage.addObject(TestHelper.data(20), forKey: "key2")
    let size = try storage.totalDiskSize()
    XCTAssertEqual(size, 30)
  }

 */
}

