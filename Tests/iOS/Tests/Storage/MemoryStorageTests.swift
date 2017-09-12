import XCTest
@testable import Cache

final class MemoryStorageTests: XCTestCase {
  private let key = "youknownothing"
  private let object = TestHelper.user
  private var storage: MemoryStorage!

  override func setUp() {
    super.setUp()
    let config = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)
    storage = MemoryStorage(config: config)
  }

  override func tearDown() {
    storage.removeAll()
    super.tearDown()
  }

  /// Test that it saves an object
  func testAddObject() {
    storage.setObject(object, forKey: key)
    let cachedObject: User = try! storage.object(forKey: key)
    XCTAssertNotNil(cachedObject)
  }

  func testCacheEntry() {
    // Returns nil if entry doesn't exist
    var entry: Entry<User> = try! storage.entry(forKey: key)
    XCTAssertNil(entry)

    // Returns entry if object exists
    let expiry = Expiry.date(Date())
    storage.setObject(object, forKey: key)
    entry = try! storage.entry(forKey: key)

    XCTAssertEqual(entry.object.firstName, object.firstName)
    XCTAssertEqual(entry.object.lastName, object.lastName)
    XCTAssertEqual(entry.expiry.date, expiry.date)
  }

  /// Test that it resolves cached object
  func testObject() {
    storage.setObject(object, forKey: key)
    let cachedObject: User = try! storage.object(forKey: key)
    XCTAssertEqual(cachedObject.firstName, object.firstName)
    XCTAssertEqual(cachedObject.lastName, object.lastName)
  }

  /// Test that it removes cached object
  func testRemoveObject() {
    storage.setObject(object, forKey: key)
    storage.removeObject(forKey: key)
    let cachedObject: User = try! storage.object(forKey: key)
    XCTAssertNil(cachedObject)
  }

  /// Test that it removes expired object
  func testRemoveObjectIfExpiredWhenExpired() {
    let expiry: Expiry = .date(Date().addingTimeInterval(-100000))
    storage.setObject(object, forKey: key)
    storage.removeObjectIfExpired(forKey: key)
    let cachedObject: User = try! storage.object(forKey: key)

    XCTAssertNil(cachedObject)
  }

  /// Test that it doesn't remove not expired object
  func testRemoveObjectIfExpiredWhenNotExpired() {
    storage.setObject(object, forKey: key)
    storage.removeObjectIfExpired(forKey: key)
    let cachedObject: User = try! storage.object(forKey: key)

    XCTAssertNotNil(cachedObject)
  }

  /// Test that it clears cache directory
  func testRemoveAll() {
    storage.setObject(object, forKey: key)
    storage.removeAll()
    let cachedObject: User = try! storage.object(forKey: key)
    XCTAssertNil(cachedObject)
  }

  /// Test that it removes expired objects
  func testClearExpired() {
    let expiry1: Expiry = .date(Date().addingTimeInterval(-100000))
    let expiry2: Expiry = .date(Date().addingTimeInterval(100000))
    let key1 = "item1"
    let key2 = "item2"
    storage.setObject(object, forKey: key1)
    storage.setObject(object, forKey: key2)
    storage.removeExpiredObjects()
    let object1: User = try! storage.object(forKey: key1)
    let object2: User = try! storage.object(forKey: key2)

    XCTAssertNil(object1)
    XCTAssertNotNil(object2)
  }
}
