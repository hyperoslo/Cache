import XCTest
import Dispatch
@testable import Cache

final class AsyncStorageTests: XCTestCase {
  private var storage: AsyncStorage<String, User>!
  let user = User(firstName: "John", lastName: "Snow")

  override func setUp() {
    super.setUp()
    let memory = MemoryStorage<String, User>(config: MemoryConfig())
    let disk = try! DiskStorage<String, User>(config: DiskConfig(name: "Async Disk"), transformer: TransformerFactory.forCodable(ofType: User.self))
    let hybrid = HybridStorage<String, User>(memoryStorage: memory, diskStorage: disk)
    storage = AsyncStorage(storage: hybrid, serialQueue: DispatchQueue(label: "Async"))
  }

  override func tearDown() {
    storage.removeAll(completion: { _ in })
    super.tearDown()
  }

  func testSetObject() throws {
    let expectation = self.expectation(description: #function)

    storage.setObject(user, forKey: "user", completion: { _ in })
    storage.object(forKey: "user", completion: { result in
      switch result {
      case .success(let cachedUser):
        XCTAssertEqual(cachedUser, self.user)
        expectation.fulfill()
      default:
        XCTFail()
      }
    })

    wait(for: [expectation], timeout: 1)
  }

  func testRemoveAll() {
    let intStorage = storage.transform(transformer: TransformerFactory.forCodable(ofType: Int.self))
    let expectation = self.expectation(description: #function)
    given("add a lot of objects") {
      Array(0..<100).forEach {
        intStorage.setObject($0, forKey: "key-\($0)", completion: { _ in })
      }
    }

    when("remove all") {
      intStorage.removeAll(completion: { _ in })
    }

    then("all are removed") {
      intStorage.objectExists(forKey: "key-99", completion: { result in
        switch result {
        case .success:
          XCTFail()
        default:
          expectation.fulfill()
        }
      })
    }

    wait(for: [expectation], timeout: 1)
  }
    
    func testAutoClearAllExpiredObjectWhenApplicationEnterBackground() {
        let expiry1: Expiry = .date(Date().addingTimeInterval(-10))
        let expiry2: Expiry = .date(Date().addingTimeInterval(10))
        let key1 = "item1"
        let key2 = "item2"
        var key1Removed = false
        var key2Removed = false
        storage.innerStorage.memoryStorage.onRemove = { key in
          key1Removed = true
          key2Removed = true
          XCTAssertTrue(key1Removed)
          XCTAssertTrue(key2Removed)
        }
            
        storage.innerStorage.diskStorage.onRemove = { path in
          key1Removed = true
          key2Removed = true
          XCTAssertTrue(key1Removed)
          XCTAssertTrue(key2Removed)
        }
        
        storage.setObject(user, forKey: key1, expiry: expiry1) { _ in
            
        }
        storage.setObject(user, forKey: key2, expiry: expiry2) { _ in
            
        }
        ///Device enters background
        NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
      }
        
    func testManualManageExpirationMode() {
        storage.applyExpiratonMode(.manual)
        let expiry1: Expiry = .date(Date().addingTimeInterval(-10))
        let expiry2: Expiry = .date(Date().addingTimeInterval(60))
        let key1 = "item1"
        let key2 = "item2"
          
        var key1Removed = false
        var key2Removed = false
        storage.innerStorage.memoryStorage.onRemove = { key in
          key1Removed = true
          key2Removed = true
          XCTAssertFalse(key1Removed)
          XCTAssertFalse(key2Removed)
        }
          
        storage.innerStorage.diskStorage.onRemove = { path in
          key1Removed = true
          key2Removed = true
          XCTAssertFalse(key1Removed)
          XCTAssertFalse(key2Removed)
        }
        
        storage.setObject(user, forKey: key1, expiry: expiry1) { _ in
            
        }
        storage.setObject(user, forKey: key2, expiry: expiry2) { _ in
            
        }
        ///Device enters background
        NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
      }
}
