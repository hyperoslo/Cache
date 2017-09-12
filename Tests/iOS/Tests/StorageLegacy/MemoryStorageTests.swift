import XCTest
@testable import Cache

final class MemoryStorageTests: XCTestCase {
  private let cacheName = "Brain"
  private let key = "youknownothing"
  private let object = TestHelper.user
  private var storage: MemoryStorage!

  override func setUp() {
    super.setUp()
    storage = MemoryStorage(name: cacheName)
  }

  override func tearDown() {
    storage.clear()
    super.tearDown()
  }

  /// Test that it saves an object
  func testAddObject() {
    storage.addObject(object, forKey: key)
    let cachedObject: User? = storage.object(forKey: key)
    XCTAssertNotNil(cachedObject)
  }

  func testCacheEntry() {
    // Returns nil if entry doesn't exist
    var entry: CacheEntry<User>? = storage.cacheEntry(forKey: key)
    XCTAssertNil(entry)

    // Returns entry if object exists
    let expiry = Expiry.date(Date())
    storage.addObject(object, forKey: key, expiry: expiry)
    entry = storage.cacheEntry(forKey: key)

    XCTAssertEqual(entry?.object.firstName, object.firstName)
    XCTAssertEqual(entry?.object.lastName, object.lastName)
    XCTAssertEqual(entry?.expiry.date, expiry.date)
  }

  /// Test that it resolves cached object
  func testObject() {
    storage.addObject(object, forKey: key)
    let cachedObject: User? = storage.object(forKey: key)
    XCTAssertEqual(cachedObject?.firstName, object.firstName)
    XCTAssertEqual(cachedObject?.lastName, object.lastName)
  }

  /// Test that it removes cached object
  func testRemoveObject() {
    storage.addObject(object, forKey: key)
    storage.removeObject(forKey: key)
    let cachedObject: User? = storage.object(forKey: key)
    XCTAssertNil(cachedObject)
  }

  /// Test that it removes expired object
  func testRemoveObjectIfExpiredWhenExpired() {
    let expiry: Expiry = .date(Date().addingTimeInterval(-100000))
    storage.addObject(object, forKey: key, expiry: expiry)
    storage.removeObjectIfExpired(forKey: key)
    let cachedObject: User? = storage.object(forKey: key)

    XCTAssertNil(cachedObject)
  }

  /// Test that it doesn't remove not expired object
  func testRemoveObjectIfExpiredWhenNotExpired() {
    storage.addObject(object, forKey: key)
    storage.removeObjectIfExpired(forKey: key)
    let cachedObject: User? = storage.object(forKey: key)

    XCTAssertNotNil(cachedObject)
  }

  /// Test that it clears cache directory
  func testClear() {
    storage.addObject(object, forKey: key)
    storage.clear()
    let cachedObject: User? = storage.object(forKey: key)
    XCTAssertNil(cachedObject)
  }

  /// Test that it removes expired objects
  func testClearExpired() {
    let expiry1: Expiry = .date(Date().addingTimeInterval(-100000))
    let expiry2: Expiry = .date(Date().addingTimeInterval(100000))
    let key1 = "item1"
    let key2 = "item2"
    storage.addObject(object, forKey: key1, expiry: expiry1)
    storage.addObject(object, forKey: key2, expiry: expiry2)
    storage.clearExpired()
    let object1: User? = storage.object(forKey: key1)
    let object2: User? = storage.object(forKey: key2)

    XCTAssertNil(object1)
    XCTAssertNotNil(object2)
  }
}
