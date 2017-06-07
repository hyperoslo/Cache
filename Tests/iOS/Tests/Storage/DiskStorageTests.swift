import XCTest
import SwiftHash
@testable import Cache

final class DiskStorageTests: XCTestCase {
  private let cacheName = "Floppy"
  private let key = "youknownothing"
  private let object = TestHelper.user
  private let fileManager = FileManager()
  private var storage: DiskStorage!

  override func setUp() {
    super.setUp()
    storage = DiskStorage(name: cacheName)
  }

  override func tearDown() {
    try? fileManager.removeItem(atPath: storage.path)
    super.tearDown()
  }

  func testInit() {
    // Test that it creates cache directory
    let fileExist = fileManager.fileExists(atPath: storage.path)
    XCTAssertTrue(fileExist)

    // Test that it returns the default maximum size of a cache
    XCTAssertEqual(storage.maxSize, 0)
  }

  /// Test that it returns the correct path
  func testDefaultPath() {
    let paths = NSSearchPathForDirectoriesInDomains(
      .cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true
    )
    let path = "\(paths.first!)/\(cacheName.capitalized)"
    XCTAssertEqual(storage.path, path)
  }

  /// Test that it returns the correct path
  func testCustomPath() throws {
    let path = try fileManager.url(
      for: .applicationSupportDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: true).path
    storage = DiskStorage(name: cacheName, cacheDirectory: path)

    XCTAssertEqual(storage.path, path)
  }

  /// Test that it sets attributes
  func testSetDirectoryAttributes() throws {
    try storage.addObject(object, forKey: key)
    try storage.setDirectoryAttributes([FileAttributeKey.immutable: true])
    let attributes = try fileManager.attributesOfItem(atPath: storage.path)

    XCTAssertTrue(attributes[FileAttributeKey.immutable] as? Bool == true)
    try storage.setDirectoryAttributes([FileAttributeKey.immutable: false])
  }

  /// Test that it saves an object
  func testAddObject() throws {
    try storage.addObject(object, forKey: key)
    let fileExist = fileManager.fileExists(atPath: storage.makeFilePath(for: key))
    XCTAssertTrue(fileExist)
  }

  /// Test that
  func testCacheEntry() throws {
    // Returns nil if entry doesn't exist
    var entry: CacheEntry<User>?
    do {
      entry = try storage.cacheEntry(forKey: key)
    } catch {}
    XCTAssertNil(entry)

    // Returns entry if object exists
    try storage.addObject(object, forKey: key)
    entry = try storage.cacheEntry(forKey: key)
    let attributes = try fileManager.attributesOfItem(atPath: storage.makeFilePath(for: key))
    let expiry = Expiry.date(attributes[FileAttributeKey.modificationDate] as! Date)

    XCTAssertEqual(entry?.object.firstName, object.firstName)
    XCTAssertEqual(entry?.object.lastName, object.lastName)
    XCTAssertEqual(entry?.expiry.date, expiry.date)
  }

  /// Test that it resolves cached object
  func testObject() throws {
    try storage.addObject(object, forKey: key)
    let cachedObject: User? = try storage.object(forKey: key)

    XCTAssertEqual(cachedObject?.firstName, object.firstName)
    XCTAssertEqual(cachedObject?.lastName, object.lastName)
  }

  /// Test that it removes cached object
  func testRemoveObject() throws {
    try storage.addObject(object, forKey: key)
    try storage.removeObject(forKey: key)
    let fileExist = fileManager.fileExists(atPath: storage.makeFilePath(for: key))
    XCTAssertFalse(fileExist)
  }

  /// Test that it removes expired object
  func testRemoveObjectIfExpiredWhenExpired() throws {
    let expiry: Expiry = .date(Date().addingTimeInterval(-100000))
    try storage.addObject(object, forKey: key, expiry: expiry)
    try storage.removeObjectIfExpired(forKey: key)
    var cachedObject: User?
    do {
      cachedObject = try storage.object(forKey: key)
    } catch {}

    XCTAssertNil(cachedObject)
  }

  /// Test that it doesn't remove not expired object
  func testRemoveObjectIfExpiredWhenNotExpired() throws {
    try storage.addObject(object, forKey: key)
    try storage.removeObjectIfExpired(forKey: key)
    let cachedObject: User? = try storage.object(forKey: key)
    XCTAssertNotNil(cachedObject)
  }

  /// Test that it clears cache directory
  func testClear() throws {
    try storage.addObject(object, forKey: key)
    try storage.clear()
    let fileExist = fileManager.fileExists(atPath: storage.path)
    XCTAssertFalse(fileExist)
  }

  /// Test that it removes expired objects
  func testClearExpired() throws {
    let expiry1: Expiry = .date(Date().addingTimeInterval(-100000))
    let expiry2: Expiry = .date(Date().addingTimeInterval(100000))
    let key1 = "item1"
    let key2 = "item2"
    try storage.addObject(object, forKey: key1, expiry: expiry1)
    try storage.addObject(object, forKey: key2, expiry: expiry2)
    try storage.clearExpired()
    var object1: User?
    let object2: User? = try storage.object(forKey: key2)

    do {
      object1 = try storage.object(forKey: key1)
    } catch {}

    XCTAssertNil(object1)
    XCTAssertNotNil(object2)
  }

  /// Test that it returns a correct file name
  func testMakeFileName() {
    XCTAssertEqual(storage.makeFileName(for: key), MD5(key))
  }

  /// Test that it returns a correct file path
  func testMakeFilePath() {
    let filePath = "\(storage.path)/\(storage.makeFileName(for: key))"
    XCTAssertEqual(storage.makeFilePath(for: key), filePath)
  }
}
