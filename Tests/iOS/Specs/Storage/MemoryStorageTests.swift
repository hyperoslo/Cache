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
  func testAdd() {
    storage.add(key, object: object)
    let receivedObject: User? = storage.object(key)
    XCTAssertNotNil(receivedObject)
  }

  func testCacheEntry() {
    // Returns nil if entry doesn't exist
    var entry: CacheEntry<User>? = storage.cacheEntry(key)
    XCTAssertNil(entry)

    // Returns entry if object exists
    let expiry = Expiry.date(Date())
    storage.add(key, object: object, expiry: expiry)
    entry = storage.cacheEntry(key)

    XCTAssertEqual(entry?.object.firstName, object.firstName)
    XCTAssertEqual(entry?.object.lastName, object.lastName)
    XCTAssertEqual(entry?.expiry.date, expiry.date)
  }

  /// Test that it resolves cached object
  func testObject() {
    storage.add(key, object: object)
    let cachedObject: User? = storage.object(key)
    XCTAssertEqual(cachedObject?.firstName, object.firstName)
    XCTAssertEqual(cachedObject?.lastName, object.lastName)
  }

  /// Test that it removes cached object
  func testRemove() {
    storage.add(key, object: object)
    storage.remove(key)
    let cachedObject: User? = storage.object(key)
    XCTAssertNil(cachedObject)
  }

  /// Test that it removes expired object
  func testRemoveIfExpiredWhenExpired() {
    let expiry: Expiry = .date(Date().addingTimeInterval(-100000))
    storage.add(key, object: object, expiry: expiry)
    storage.removeIfExpired(key)
    let receivedObject: User? = storage.object(key)

    XCTAssertNil(receivedObject)
  }

  /// Test that it doesn't remove not expired object
  func testRemoveIfExpiredWhenNotExpired() {
    storage.add(key, object: object)
    storage.removeIfExpired(key)
    let receivedObject: User? = storage.object(key)

    XCTAssertNotNil(receivedObject)
  }

  /// Test that it clears cache directory
  func testClear() {
    storage.add(key, object: object)
    storage.clear()
    let receivedObject: User? = storage.object(key)
    XCTAssertNil(receivedObject)
  }

  /// Test that it removes expired objects
  func testClearExpired() {
    let expiry1: Expiry = .date(Date().addingTimeInterval(-100000))
    let expiry2: Expiry = .date(Date().addingTimeInterval(100000))
    let key1 = "item1"
    let key2 = "item2"
    storage.add(key1, object: object, expiry: expiry1)
    storage.add(key2, object: object, expiry: expiry2)
    storage.clearExpired()
    let object1: User? = storage.object(key1)
    let object2: User? = storage.object(key2)

    XCTAssertNil(object1)
    XCTAssertNotNil(object2)
  }
}
