import XCTest
@testable import Cache

final class MemoryStorageTests: XCTestCase {
  private let key = "youknownothing"
  private let testObject = User(firstName: "John", lastName: "Snow")
  private var storage: MemoryStorage<String, User>!

  /// 16 bytes, can contain 2 objects
  private let config = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 16)

  override func setUp() {
    super.setUp()
    storage = MemoryStorage<String, User>(config: config)
  }

  override func tearDown() {
    storage.removeAll()
    super.tearDown()
  }

  /// Test that it saves an object
  func testSetObject() {
    storage.setObject(testObject, forKey: key)
    let cachedObject = try! storage.object(forKey: key)
    XCTAssertNotNil(cachedObject)
    XCTAssertEqual(cachedObject.firstName, testObject.firstName)
    XCTAssertEqual(cachedObject.lastName, testObject.lastName)
  }

  func testCacheEntry() {
    // Returns nil if entry doesn't exist
    var entry = try? storage.entry(forKey: key)
    XCTAssertNil(entry)

    // Returns entry if object exists
    storage.setObject(testObject, forKey: key)
    entry = try! storage.entry(forKey: key)

    XCTAssertEqual(entry?.object.firstName, testObject.firstName)
    XCTAssertEqual(entry?.object.lastName, testObject.lastName)
    XCTAssertEqual(entry?.expiry.date, config.expiry.date)
  }
  
  func testSetObjectWithExpiry() {
    let date = Date().addingTimeInterval(1)
    storage.setObject(testObject, forKey: key, expiry: .seconds(1))
    var entry = try! storage.entry(forKey: key)
    XCTAssertEqual(entry.expiry.date.timeIntervalSinceReferenceDate,
                   date.timeIntervalSinceReferenceDate,
                   accuracy: 0.1)
    //Timer vs sleep: do not complicate
    sleep(1)
    entry = try! storage.entry(forKey: key)
    XCTAssertEqual(entry.expiry.date.timeIntervalSinceReferenceDate,
                   date.timeIntervalSinceReferenceDate,
                   accuracy: 0.1)
  }

  /// Test that it removes cached object
  func testRemoveObject() {
    storage.setObject(testObject, forKey: key)
    storage.removeObject(forKey: key)
    let cachedObject = try? storage.object(forKey: key)
    XCTAssertNil(cachedObject)
  }

  /// Test that it removes expired object
  func testRemoveObjectIfExpiredWhenExpired() {
    let expiry: Expiry = .date(Date().addingTimeInterval(-10))
    storage.setObject(testObject, forKey: key, expiry: expiry)
    storage.removeObjectIfExpired(forKey: key)
    let cachedObject = try? storage.object(forKey: key)

    XCTAssertNil(cachedObject)
  }

  /// Test that it doesn't remove not expired object
  func testRemoveObjectIfExpiredWhenNotExpired() {
    storage.setObject(testObject, forKey: key)
    storage.removeObjectIfExpired(forKey: key)
    let cachedObject = try! storage.object(forKey: key)

    XCTAssertNotNil(cachedObject)
  }
  
  /// Test expired object
  func testExpiredObject() throws {
    storage.setObject(testObject, forKey: key, expiry: .seconds(0.9))
    XCTAssertFalse(try! storage.isExpiredObject(forKey: key))
    sleep(1)
    XCTAssertTrue(try! storage.isExpiredObject(forKey: key))
  }

  /// Test that it clears cache directory
  func testRemoveAll() {
    storage.setObject(testObject, forKey: key)
    storage.removeAll()
    let cachedObject = try? storage.object(forKey: key)
    XCTAssertNil(cachedObject)
  }

  /// Test that it removes expired objects
  func testClearExpired() {
    let expiry1: Expiry = .date(Date().addingTimeInterval(-10))
    let expiry2: Expiry = .date(Date().addingTimeInterval(10))
    let key1 = "item1"
    let key2 = "item2"
    storage.onRemove = { key in
        XCTAssertTrue(key == key1)
    }
    storage.setObject(testObject, forKey: key1, expiry: expiry1)
    storage.setObject(testObject, forKey: key2, expiry: expiry2)
    storage.removeExpiredObjects()
    
    let object1 = try? storage.object(forKey: key1)
    let object2 = try! storage.object(forKey: key2)

    XCTAssertNil(object1)
    XCTAssertNotNil(object2)
  }
    
    
    func testAutoClearAllExpiredObjectWhenApplicationEnterBackground() {
        let expiry1: Expiry = .date(Date().addingTimeInterval(-10))
        let expiry2: Expiry = .date(Date().addingTimeInterval(10))
        let key1 = "item1"
        let key2 = "item2"
        storage.onRemove = { key in
            XCTAssertTrue(key == key1)
        }
        storage.setObject(testObject, forKey: key1, expiry: expiry1)
        storage.setObject(testObject, forKey: key2, expiry: expiry2)
        ///Device enters background
        NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    func testManualManageExpirationMode() {
        storage.applyExpiratonMode(.manual)
        let expiry1: Expiry = .date(Date().addingTimeInterval(-10))
        let expiry2: Expiry = .date(Date().addingTimeInterval(10))
        let key1 = "item1"
        let key2 = "item2"
        var success = true
        storage.onRemove = { key in
            success = false
            XCTAssertTrue(success)
        }
        storage.setObject(testObject, forKey: key1, expiry: expiry1)
        storage.setObject(testObject, forKey: key2, expiry: expiry2)
            ///Device enters background
        NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    ///we have set max cost 16 bytes, so the first object is released
    func testCost() {
        let key1 = "item1"
        let key2 = "item2"
        let key3 = "item3"
        storage.setObject(testObject, forKey: key1)
        storage.setObject(testObject, forKey: key2)
        storage.setObject(testObject, forKey: key3)
        
        let object1 = try? storage.object(forKey: key1)
        let object2 = try! storage.object(forKey: key2)
        let object3 = try! storage.object(forKey: key2)
        XCTAssertNotNil(object2)
        XCTAssertNotNil(object3)
        XCTAssertNil(object1)
    }
    
    
}
