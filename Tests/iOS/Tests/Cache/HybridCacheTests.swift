import XCTest
@testable import Cache

final class HybridCacheTests: XCTestCase {
  private let cacheName = "WeirdoCache"
  private let key = "alongweirdkey"
  private let object = "Test"
  private var cache: HybridCache!
  private let fileManager = FileManager()

  override func setUp() {
    super.setUp()
    cache = HybridCache(name: cacheName)
  }

  override func tearDown() {
    try? cache.clear()
    super.tearDown()
  }

  func testInit() {
    let defaultConfig = Config()

    XCTAssertEqual(cache.name, cacheName)
    XCTAssertEqual(cache.manager.config.expiry.date, defaultConfig.expiry.date)
    XCTAssertNil(cache.manager.config.cacheDirectory)
    XCTAssertEqual(cache.manager.config.maxDiskSize, defaultConfig.maxDiskSize)
    XCTAssertEqual(cache.manager.config.memoryCountLimit, defaultConfig.memoryCountLimit)
    XCTAssertEqual(cache.manager.config.memoryTotalCostLimit, defaultConfig.memoryTotalCostLimit)
    XCTAssertTrue(cache.manager.config.cacheDirectory == defaultConfig.cacheDirectory)
  }

  // MARK: - Async caching

  func testAsyncAddObject() throws {
    let expectation1 = self.expectation(description: "Save Expectation")
    let expectation2 = self.expectation(description: "Save To Memory Expectation")
    let expectation3 = self.expectation(description: "Save To Disk Expectation")

    cache.async.addObject(object, forKey: key) { error in
      if let error = error {
        XCTFail("Failed with error: \(error)")
      }

      self.cache.async.object(forKey: self.key) { (cachedObject: String?) in
        XCTAssertNotNil(cachedObject)
        expectation1.fulfill()
      }


      let memoryObject: String? = self.cache.manager.frontStorage.object(forKey: self.key)
      XCTAssertNotNil(memoryObject)
      expectation2.fulfill()

      let diskObject: String? = try! self.cache.manager.backStorage.object(forKey: self.key)
      XCTAssertNotNil(diskObject)
      expectation3.fulfill()
    }

    self.waitForExpectations(timeout: 1.0, handler:nil)
  }

  func testAsyncCacheEntry() {
    let expectation = self.expectation(description: "Save Expectation")
    let expiryDate = Date()
    cache.async.addObject(object, forKey: key, expiry: .date(expiryDate)) { error in
      if let error = error {
        XCTFail("Failed with error: \(error)")
      }

      self.cache.async.cacheEntry(forKey: self.key) { (entry: CacheEntry<String>?) in
        XCTAssertEqual(entry?.object, self.object)
        XCTAssertEqual(entry?.expiry.date, expiryDate)
        expectation.fulfill()
      }
    }
    self.waitForExpectations(timeout: 1.0, handler:nil)
  }

  func testAsyncObject() {
    let expectation = self.expectation(description: "Expectation")
    cache.async.addObject(object, forKey: key) { error in
      if let error = error {
        XCTFail("Failed with error: \(error)")
      }
      self.cache.async.object(forKey: self.key) { (cachedObject: String?) in
        XCTAssertNotNil(cachedObject)
        XCTAssertEqual(cachedObject, self.object)
        expectation.fulfill()
      }
    }
    self.waitForExpectations(timeout: 1.0, handler:nil)
  }

  /// Should resolve from disk and set in-memory cache if object not in-memory
  func testAsyncObjectCopyToMemory() throws {
    let expectation = self.expectation(description: "Expectation")

    try cache.manager.backStorage.addObject(object, forKey: key)
    cache.async.object(forKey: key) { (cachedObject: String?) in
      XCTAssertNotNil(cachedObject)
      XCTAssertEqual(cachedObject, self.object)

      let inMemoryCachedObject: String? = self.cache.manager.frontStorage.object(forKey: self.key)
      XCTAssertEqual(inMemoryCachedObject, self.object)

      expectation.fulfill()
    }

    self.waitForExpectations(timeout: 1.0, handler:nil)
  }

  /// Removes cached object from memory and disk
  func testAsyncRemoveObject() {
    let expectation1 = self.expectation(description: "Remove Expectation")
    let expectation2 = self.expectation(description: "Remove From Memory Expectation")
    let expectation3 = self.expectation(description: "Remove From Disk Expectation")

    cache.async.addObject(object, forKey: key) { error in
      if let error = error {
        XCTFail("Failed with error: \(error)")
      }
      self.cache.async.removeObject(forKey: self.key) { error in
        if let error = error {
          XCTFail("Failed with error: \(error)")
        }

        self.cache.async.object(forKey: self.key) { (cachedObject: String?) in
          XCTAssertNil(cachedObject)
          expectation1.fulfill()
        }

        let memoryObject: String? = self.cache.manager.frontStorage.object(forKey: self.key)
        XCTAssertNil(memoryObject)
        expectation2.fulfill()

        var diskObject: String?
        do {
          diskObject = try self.cache.manager.backStorage.object(forKey: self.key)
        } catch {}

        XCTAssertNil(diskObject)
        expectation3.fulfill()
      }
    }

    self.waitForExpectations(timeout: 1.0, handler:nil)
  }

  /// Clears memory and disk cache
  func testAsyncClear() {
    let expectation1 = self.expectation(description: "Clear Expectation")
    let expectation2 = self.expectation(description: "Clear Memory Expectation")
    let expectation3 = self.expectation(description: "Clear Disk Expectation")

    cache.async.addObject(object, forKey: key) { error in
      if let error = error {
        XCTFail("Failed with error: \(error)")
      }
      self.cache.async.clear() { error in
        if let error = error {
          XCTFail("Failed with error: \(error)")
        }

        self.cache.async.object(forKey: self.key) { (cachedObject: String?) in
          XCTAssertNil(cachedObject)
          expectation1.fulfill()
        }

        let memoryObject: String? = self.cache.manager.frontStorage.object(forKey: self.key)
        XCTAssertNil(memoryObject)
        expectation2.fulfill()

        var diskObject: String?
        do {
          diskObject = try self.cache.manager.backStorage.object(forKey: self.key)
        } catch {}
        XCTAssertNil(diskObject)
        expectation3.fulfill()
      }
    }
    self.waitForExpectations(timeout: 1.0, handler:nil)
  }

  /// Test that it clears cached files, but keeps root directory
  func testAsyncClearKeepingRootDirectory() throws {
    let expectation1 = self.expectation(description: "Clear Expectation")

    cache.async.addObject(object, forKey: key) { error in
      if let error = error {
        XCTFail("Failed with error: \(error)")
      }
      self.cache.async.clear(keepingRootDirectory: true) { error in
        if let error = error {
          XCTFail("Failed with error: \(error)")
        }

        self.cache.async.object(forKey: self.key) { (cachedObject: String?) in
          XCTAssertNil(cachedObject)
          XCTAssertTrue(self.fileManager.fileExists(atPath: self.cache.manager.backStorage.path))
          expectation1.fulfill()
        }
      }
    }
    self.waitForExpectations(timeout: 1.0, handler:nil)
  }

  /// Clears expired objects from memory and disk cache
  func testAsyncClearExpired() {
    let expectation1 = self.expectation(description: "Clear If Expired Expectation")
    let expectation2 = self.expectation(description: "Don't Clear If Not Expired Expectation")
    let expiry1: Expiry = .date(Date().addingTimeInterval(-100000))
    let expiry2: Expiry = .date(Date().addingTimeInterval(100000))
    let key1 = "key1"
    let key2 = "key2"

    cache.async.addObject(object, forKey: key1, expiry: expiry1) { error in
      if let error = error {
        XCTFail("Failed with error: \(error)")
      }
      self.cache.async.addObject(self.object, forKey: key2, expiry: expiry2) { error in
        if let error = error {
          XCTFail("Failed with error: \(error)")
        }
        self.cache.async.clearExpired() { error in
          if let error = error {
            XCTFail("Failed with error: \(error)")
          }
          self.cache.async.object(forKey: key1) { (cachedObject: String?) in
            XCTAssertNil(cachedObject)
            expectation1.fulfill()
          }
          self.cache.async.object(forKey: key2) { (cachedObject: String?) in
            XCTAssertNotNil(cachedObject)
            expectation2.fulfill()
          }
        }
      }
    }

    self.waitForExpectations(timeout: 1.0, handler:nil)
  }

  // MARK: - Sync caching

  func testAdd() throws {
    try cache.addObject(object, forKey: key)
    let cachedObject: String? = cache.object(forKey: key)
    XCTAssertNotNil(cachedObject)

    let memoryObject: String? = cache.manager.frontStorage.object(forKey: self.key)
    XCTAssertNotNil(memoryObject)

    let diskObject: String? = try cache.manager.backStorage.object(forKey: self.key)
    XCTAssertNotNil(diskObject)
  }

  func testCacheEntry() throws {
    let expiryDate = Date()
    try cache.addObject(object, forKey: key, expiry: .date(expiryDate))
    let entry: CacheEntry<String>? = cache.cacheEntry(forKey: key)

    XCTAssertEqual(entry?.object, self.object)
    XCTAssertEqual(entry?.expiry.date, expiryDate)
  }

  func testObject() throws {
    try cache.addObject(object, forKey: key)
    let cachedObject: String? = cache.object(forKey: key)

    XCTAssertNotNil(cachedObject)
    XCTAssertEqual(cachedObject, self.object)
  }

  /// Should resolve from disk and set in-memory cache if object not in-memory
  func testObjectCopyToMemory() throws {
    try cache.manager.backStorage.addObject(object, forKey: key)
    let cachedObject: String? = cache.object(forKey: key)

    XCTAssertNotNil(cachedObject)
    XCTAssertEqual(cachedObject, object)

    let inMemoryCachedObject: String? = cache.manager.frontStorage.object(forKey: key)
    XCTAssertEqual(inMemoryCachedObject, object)
  }

  /// Removes cached object from memory and disk
  func testRemoveObject() throws {
    try cache.addObject(object, forKey: key)
    XCTAssertNotNil(cache.object(forKey: key) as String?)

    try cache.removeObject(forKey: key)
    XCTAssertNil(cache.object(forKey: key) as String?)

    let memoryObject: String? = self.cache.manager.frontStorage.object(forKey: self.key)
    XCTAssertNil(memoryObject)

    var diskObject: String?
    do {
      diskObject = try self.cache.manager.backStorage.object(forKey: self.key)
    } catch {}

    XCTAssertNil(diskObject)
  }

  /// Clears memory and disk cache
  func testClear() throws {
    try cache.addObject(object, forKey: key)
    try cache.clear()
    XCTAssertNil(cache.object(forKey: key) as String?)

    let memoryObject: String? = self.cache.manager.frontStorage.object(forKey: self.key)
    XCTAssertNil(memoryObject)

    var diskObject: String?
    do {
      diskObject = try self.cache.manager.backStorage.object(forKey: self.key)
    } catch {}
    XCTAssertNil(diskObject)
  }

  /// Test that it clears cached files, but keeps root directory
  func testClearKeepingRootDirectory() throws {
    try cache.addObject(object, forKey: key)
    try cache.clear(keepingRootDirectory: true)
    XCTAssertNil(cache.object(forKey: key) as String?)
    XCTAssertTrue(fileManager.fileExists(atPath: cache.manager.backStorage.path))
  }

  /// Clears expired objects from memory and disk cache
  func testClearExpired() throws {
    let expiry1: Expiry = .date(Date().addingTimeInterval(-100000))
    let expiry2: Expiry = .date(Date().addingTimeInterval(100000))
    let key1 = "key1"
    let key2 = "key2"

    try cache.addObject(object, forKey: key1, expiry: expiry1)
    try cache.addObject(object, forKey: key2, expiry: expiry2)
    try cache.clearExpired()
    XCTAssertNil(cache.object(forKey: key1) as String?)
    XCTAssertNotNil(cache.object(forKey: key2) as String?)
  }

  func testTotalDiskSize() throws {
    let cache = SpecializedCache<Data>(name: cacheName)
    try cache.addObject(TestHelper.data(10), forKey: "key1")
    try cache.addObject(TestHelper.data(20), forKey: "key2")
    let size = try cache.totalDiskSize()
    XCTAssertEqual(size, 30)
  }
}
