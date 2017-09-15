import XCTest
@testable import Cache

final class StorageTests: XCTestCase {
  private var interalStorage: StorageAware!
  private var storage: Storage!
  let user = User(firstName: "John", lastName: "Snow")

  override func setUp() {
    super.setUp()

    storage = try! Storage(diskConfig: DiskConfig(name: "Thor"), memoryConfig: MemoryConfig())
    interalStorage = storage.internalStorage
  }

  override func tearDown() {
    try? interalStorage.removeAll()
    super.tearDown()
  }

  func testSync() throws {
    try storage.sync.setObject(user, forKey: "user")
    let cachedObject = try storage.sync.object(forKey: "user") as User

    XCTAssertEqual(cachedObject, user)
  }

  func testAsync() {
    let expectation = self.expectation(description: #function)
    storage.async.setObject(user, forKey: "user", completion: { _ in })

    storage.async.object(forKey: "user", completion: { (result: Result<User>) in
      switch result {
      case .value(let cachedUser):
        XCTAssertEqual(cachedUser, self.user)
        expectation.fulfill()
      default:
        XCTFail()
      }
    })

    wait(for: [expectation], timeout: 1)
  }
}


