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

  func testSetObject() async throws {
    try await storage.setObject(user, forKey: "user")
    let cachedUser = try await storage.object(forKey: "user")

    XCTAssertEqual(cachedUser, self.user)
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

  func testRemoveAll() async throws {
    let intStorage = storage.transform(transformer: TransformerFactory.forCodable(ofType: Int.self))
    try await given("add a lot of objects") {
      for i in 0 ..< 100 {
        try await intStorage.setObject(i, forKey: "key-\(i)")
      }
    }

    try await when("remove all") {
      try await intStorage.removeAll()
    }

    await then("all are removed") {
      do {
        _ = try await intStorage.objectExists(forKey: "key-99")
        XCTFail()
      } catch {}
    }
  }
}
