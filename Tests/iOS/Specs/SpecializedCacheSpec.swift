import XCTest
@testable import Cache

class SpecializedCacheTests: XCTestCase {
  let cacheName = "WeirdoCache"
  let key = "alongweirdkey"
  let object = SpecHelper.user
  var cache: SpecializedCache<User>!

  override func setUp() {
    super.setUp()
    cache = SpecializedCache<User>(name: cacheName)
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

  func testAsyncAddObject() {
    let expectation1 = self.expectation(description: "Save Expectation")
    let expectation2 = self.expectation(description: "Save To Memory Expectation")
    let expectation3 = self.expectation(description: "Save To Disk Expectation")

    cache.async.addObject(object, forKey: key) { error in
      if let error = error {
        XCTFail("Failed with error: \(error)")
      }

      self.cache.async.object(forKey: self.key) { receivedObject in
        XCTAssertNotNil(receivedObject)
        expectation1.fulfill()
      }


      let memoryObject: User? = self.cache.manager.frontStorage.object(self.key)
      XCTAssertNotNil(memoryObject)
      expectation2.fulfill()

      let diskObject: User? = try! self.cache.manager.backStorage.object(self.key)
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

      self.cache.async.cacheEntry(forKey: self.key) { entry in
        XCTAssertEqual(entry?.object.firstName, self.object.firstName)
        XCTAssertEqual(entry?.object.lastName, self.object.lastName)
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
      self.cache.async.object(forKey: self.key) { receivedObject in
        XCTAssertNotNil(receivedObject)
        XCTAssertEqual(receivedObject?.firstName, self.object.firstName)
        XCTAssertEqual(receivedObject?.lastName, self.object.lastName)
        expectation.fulfill()
      }
    }
    self.waitForExpectations(timeout: 1.0, handler:nil)
  }

  /// Should resolve from disk and set in-memory cache if object not in-memory
  func testAsyncObjectCopyToMemory() {
    let expectation = self.expectation(description: "Expectation")

    try! cache.manager.backStorage.add(key, object: object)
    cache.async.object(forKey: key) { receivedObject in
      XCTAssertNotNil(receivedObject)
      XCTAssertEqual(receivedObject?.firstName, self.object.firstName)
      XCTAssertEqual(receivedObject?.lastName, self.object.lastName)

      let inMemoryCachedUser: User? = self.cache.manager.frontStorage.object(self.key)
      XCTAssertEqual(inMemoryCachedUser?.firstName, self.object.firstName)
      XCTAssertEqual(inMemoryCachedUser?.lastName, self.object.lastName)

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

        self.cache.async.object(forKey: self.key) { object in
          XCTAssertNil(object)
          expectation1.fulfill()
        }

        let memoryObject: User? = self.cache.manager.frontStorage.object(self.key)
        XCTAssertNil(memoryObject)
        expectation2.fulfill()

        var diskObject: User?
        do {
          diskObject = try self.cache.manager.backStorage.object(self.key)
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

        self.cache.async.object(forKey: self.key) { object in
          XCTAssertNil(object)
          expectation1.fulfill()
        }

        let memoryObject: User? = self.cache.manager.frontStorage.object(self.key)
        XCTAssertNil(memoryObject)
        expectation2.fulfill()

        var diskObject: User?
        do {
          diskObject = try self.cache.manager.backStorage.object(self.key)
        } catch {}
        XCTAssertNil(diskObject)
        expectation3.fulfill()
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
          self.cache.async.object(forKey: key1) { object in
            XCTAssertNil(object)
            expectation1.fulfill()
          }
          self.cache.async.object(forKey: key2) { object in
            XCTAssertNotNil(object)
            expectation2.fulfill()
          }
        }
      }
    }

    self.waitForExpectations(timeout: 1.0, handler:nil)
  }

  // MARK: - Sync caching

  func testAdd() {
    do {
      try cache.addObject(object, forKey: key)

      let receivedObject = cache.object(forKey: key)
      XCTAssertNotNil(receivedObject)

      let memoryObject: User? = cache.manager.frontStorage.object(self.key)
      XCTAssertNotNil(memoryObject)

      let diskObject: User? = try! cache.manager.backStorage.object(self.key)
      XCTAssertNotNil(diskObject)
    } catch {
      XCTFail("Failed with error: \(error)")
    }
  }

  func testCacheEntry() {
    let expiryDate = Date()
    do {
      try cache.addObject(object, forKey: key, expiry: .date(expiryDate))
      let entry = cache.cacheEntry(forKey: key)

      XCTAssertEqual(entry?.object.firstName, self.object.firstName)
      XCTAssertEqual(entry?.object.lastName, self.object.lastName)
      XCTAssertEqual(entry?.expiry.date, expiryDate)
    } catch {
      XCTFail("Failed with error: \(error)")
    }
  }

  func testObject() {
    do {
      try cache.addObject(object, forKey: key)
      let receivedObject = cache.object(forKey: key)

      XCTAssertNotNil(receivedObject)
      XCTAssertEqual(receivedObject?.firstName, self.object.firstName)
      XCTAssertEqual(receivedObject?.lastName, self.object.lastName)
    } catch {
      XCTFail("Failed with error: \(error)")
    }
  }

  /// Should resolve from disk and set in-memory cache if object not in-memory
  func testObjectCopyToMemory() {
    do {
      try cache.manager.backStorage.add(key, object: object)
      let receivedObject = cache.object(forKey: key)

      XCTAssertNotNil(receivedObject)
      XCTAssertEqual(receivedObject?.firstName, object.firstName)
      XCTAssertEqual(receivedObject?.lastName, object.lastName)

      let inmemoryCachedUser: User? = cache.manager.frontStorage.object(key)
      XCTAssertEqual(inmemoryCachedUser?.firstName, object.firstName)
      XCTAssertEqual(inmemoryCachedUser?.lastName, object.lastName)
    } catch {
      XCTFail("Failed with error: \(error)")
    }
  }

  /// Removes cached object from memory and disk
  func testRemoveObject() {
    do {
      try cache.addObject(object, forKey: key)
      XCTAssertNotNil(cache.object(forKey: key))

      try cache.removeObject(forKey: key)
      XCTAssertNil(cache.object(forKey: key))

      let memoryObject: User? = self.cache.manager.frontStorage.object(self.key)
      XCTAssertNil(memoryObject)

      var diskObject: User?
      do {
        diskObject = try self.cache.manager.backStorage.object(self.key)
      } catch {}

      XCTAssertNil(diskObject)
    } catch {
      XCTFail("Failed with error: \(error)")
    }
  }

  /// Clears memory and disk cache
  func testClear() {
    do {
      try cache.addObject(object, forKey: key)
      try cache.clear()

      XCTAssertNil(cache.object(forKey: key))

      let memoryObject: User? = self.cache.manager.frontStorage.object(self.key)
      XCTAssertNil(memoryObject)

      var diskObject: User?
      do {
        diskObject = try self.cache.manager.backStorage.object(self.key)
      } catch {}
      XCTAssertNil(diskObject)
    } catch {
      XCTFail("Failed with error: \(error)")
    }
  }

  /// Clears expired objects from memory and disk cache
  func testClearExpired() {
    let expiry1: Expiry = .date(Date().addingTimeInterval(-100000))
    let expiry2: Expiry = .date(Date().addingTimeInterval(100000))
    let key1 = "key1"
    let key2 = "key2"

    do {
      try cache.addObject(object, forKey: key1, expiry: expiry1)
      try cache.addObject(object, forKey: key2, expiry: expiry2)
      try cache.clearExpired()
      XCTAssertNil(cache.object(forKey: key1))
      XCTAssertNotNil(cache.object(forKey: key2))
    } catch {
      XCTFail("Failed with error: \(error)")
    }
  }
}
