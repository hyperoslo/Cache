import XCTest
@testable import Cache

final class DiskStorageTests: XCTestCase {
  private let key = "youknownothing"
  private let testObject = User(firstName: "John", lastName: "Snow")
  private let fileManager = FileManager()
  private var storage: DiskStorage<String, User>!
  private let config = DiskConfig(name: "Floppy")

  override func setUp() {
    super.setUp()
    storage = try! DiskStorage<String, User>(config: config, transformer: TransformerFactory.forCodable(ofType: User.self))
  }

  override func tearDown() {
    try? storage.removeAll()
    super.tearDown()
  }

  func testInit() {
    // Test that it creates cache directory
    let fileExist = fileManager.fileExists(atPath: storage.path)
    XCTAssertTrue(fileExist)

    // Test that it returns the default maximum size of a cache
    XCTAssertEqual(config.maxSize, 0)
  }

  /// Test that it returns the correct path
  func testDefaultPath() {
    let paths = NSSearchPathForDirectoriesInDomains(
      .cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true
    )
    let path = "\(paths.first!)/\(config.name.capitalized)"
    XCTAssertEqual(storage.path, path)
  }

  /// Test that it returns the correct path
  func testCustomPath() throws {
    let url = try fileManager.url(
      for: .applicationSupportDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: true
    )

    let customConfig = DiskConfig(name: "SSD", directory: url)

    storage = try DiskStorage<String, User>(config: customConfig, transformer: TransformerFactory.forCodable(ofType: User.self))

    XCTAssertEqual(
      storage.path,
      url.appendingPathComponent("SSD", isDirectory: true).path
    )
  }

  /// Test that it sets attributes
  func testSetDirectoryAttributes() throws {
    try storage.setObject(testObject, forKey: key)
    try storage.setDirectoryAttributes([FileAttributeKey.immutable: true])
    let attributes = try fileManager.attributesOfItem(atPath: storage.path)

    XCTAssertTrue(attributes[FileAttributeKey.immutable] as? Bool == true)
    try storage.setDirectoryAttributes([FileAttributeKey.immutable: false])
  }

  /// Test that it saves an object
  func testsetObject() throws {
    try storage.setObject(testObject, forKey: key)
    let fileExist = fileManager.fileExists(atPath: storage.makeFilePath(for: key))
    XCTAssertTrue(fileExist)
  }

  /// Test that
  func testCacheEntry() throws {
    // Returns nil if entry doesn't exist
    var entry: Entry<User>?
    do {
      entry = try storage.entry(forKey: key)
    } catch {}
    XCTAssertNil(entry)

    // Returns entry if object exists
    try storage.setObject(testObject, forKey: key)
    entry = try storage.entry(forKey: key)
    let attributes = try fileManager.attributesOfItem(atPath: storage.makeFilePath(for: key))
    let expiry = Expiry.date(attributes[FileAttributeKey.modificationDate] as! Date)

    XCTAssertEqual(entry?.object.firstName, testObject.firstName)
    XCTAssertEqual(entry?.object.lastName, testObject.lastName)
    XCTAssertEqual(entry?.expiry.date, expiry.date)
  }

  func testCacheEntryPath() throws {
    let key = "test.mp4"
    try storage.setObject(testObject, forKey: key)
    let entry = try storage.entry(forKey: key)
    let filePath = storage.makeFilePath(for: key)

    XCTAssertEqual(entry.filePath, filePath)
  }

  /// Test that it resolves cached object
  func testSetObject() throws {
    try storage.setObject(testObject, forKey: key)
    let cachedObject: User? = try storage.object(forKey: key)

    XCTAssertEqual(cachedObject?.firstName, testObject.firstName)
    XCTAssertEqual(cachedObject?.lastName, testObject.lastName)
  }

  /// Test that it removes cached object
  func testRemoveObject() throws {
    try storage.setObject(testObject, forKey: key)
    try storage.removeObject(forKey: key)
    let fileExist = fileManager.fileExists(atPath: storage.makeFilePath(for: key))
    XCTAssertFalse(fileExist)
  }

  /// Test that it removes expired object
  func testRemoveObjectIfExpiredWhenExpired() throws {
    let expiry: Expiry = .date(Date().addingTimeInterval(-100000))
    try storage.setObject(testObject, forKey: key, expiry: expiry)
    try storage.removeObjectIfExpired(forKey: key)
    var cachedObject: User?
    do {
      cachedObject = try storage.object(forKey: key)
    } catch {}

    XCTAssertNil(cachedObject)
  }

  /// Test that it doesn't remove not expired object
  func testRemoveObjectIfExpiredWhenNotExpired() throws {
    try storage.setObject(testObject, forKey: key)
    try storage.removeObjectIfExpired(forKey: key)
    let cachedObject: User? = try storage.object(forKey: key)
    XCTAssertNotNil(cachedObject)
  }
  
  /// Test expired object
  func testExpiredObject() throws {
    try storage.setObject(testObject, forKey: key, expiry: .seconds(0.9))
    XCTAssertFalse(try! storage.isExpiredObject(forKey: key))
    sleep(1)
    XCTAssertTrue(try! storage.isExpiredObject(forKey: key))
  }

  /// Test that it clears cache directory
  func testClear() throws {
    try given("create some files inside folder so that it is not empty") {
      try storage.setObject(testObject, forKey: key)
    }

    when("call removeAll to remove the whole the folder") {
      do {
        try storage.removeAll()
      } catch {
        XCTFail(error.localizedDescription)
      }
    }

    then("the folder should exist") {
      let fileExist = fileManager.fileExists(atPath: storage.path)
      XCTAssertTrue(fileExist)
    }

    then("the folder should be empty") {
      let contents = try? fileManager.contentsOfDirectory(atPath: storage.path)
      XCTAssertEqual(contents?.count, 0)
    }
}

  /// Test that it clears cache files, but keeps root directory
  func testCreateDirectory() {
    do {
      try storage.removeAll()
      XCTAssertTrue(fileManager.fileExists(atPath: storage.path))
      let contents = try? fileManager.contentsOfDirectory(atPath: storage.path)
      XCTAssertEqual(contents?.count, 0)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }

  /// Test that it removes expired objects
  func testClearExpired() throws {
    let expiry1: Expiry = .date(Date().addingTimeInterval(-100000))
    let expiry2: Expiry = .date(Date().addingTimeInterval(100000))
    let key1 = "item1"
    let key2 = "item2"
    try storage.setObject(testObject, forKey: key1, expiry: expiry1)
    try storage.setObject(testObject, forKey: key2, expiry: expiry2)
    try storage.removeExpiredObjects()
    var object1: User?
    let object2 = try storage.object(forKey: key2)

    do {
      object1 = try storage.object(forKey: key1)
    } catch {}

    XCTAssertNil(object1)
    XCTAssertNotNil(object2)
  }

  /// Test that it returns a correct file name
  func testMakeFileName() {
    XCTAssertEqual(storage.makeFileName(for: key), MD5(key))
    XCTAssertEqual(storage.makeFileName(for: "test.mp4"), "\(MD5("test.mp4")).mp4")
  }

  /// Test that it returns a correct file path
  func testMakeFilePath() {
    let filePath = "\(storage.path)/\(storage.makeFileName(for: key))"
    XCTAssertEqual(storage.makeFilePath(for: key), filePath)
  }
    
  func testAutoClearAllExpiredObjectWhenApplicationEnterBackground() {
    let expiry1: Expiry = .date(Date().addingTimeInterval(-10))
    let expiry2: Expiry = .date(Date().addingTimeInterval(10))
    let key1 = "item1"
    let key2 = "item2"
    let filePathForKey1 = storage.makeFilePath(for: key1)
    storage.onRemove = { key in
      XCTAssertTrue(key == filePathForKey1)
    }
    try? storage.setObject(testObject, forKey: key1, expiry: expiry1)
    try? storage.setObject(testObject, forKey: key2, expiry: expiry2)
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
        try? storage.setObject(testObject, forKey: key1, expiry: expiry1)
        try? storage.setObject(testObject, forKey: key2, expiry: expiry2)
            ///Device enters background
        NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
}

