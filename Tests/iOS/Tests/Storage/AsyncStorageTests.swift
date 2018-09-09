import XCTest
import Dispatch
@testable import Cache

final class AsyncStorageTests: XCTestCase {
  private var storage: AsyncStorage<User>!
  let user = User(firstName: "John", lastName: "Snow")
  let userTwo = User(firstName: "Jamie", lastName: "Lannister")

  override func setUp() {
    super.setUp()
    let memory = MemoryStorage<User>(config: MemoryConfig())
    let disk = try! DiskStorage<User>(config: DiskConfig(name: "Async Disk"), transformer: TransformerFactory.forCodable(ofType: User.self))
    let hybrid = HybridStorage<User>(memoryStorage: memory, diskStorage: disk)
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
      case .value(let cachedUser):
        XCTAssertEqual(cachedUser, self.user)
        expectation.fulfill()
      default:
        XCTFail()
      }
    })

    wait(for: [expectation], timeout: 1)
  }

  func testGettingObjects() throws {
    let expectation = self.expectation(description: #function)

    storage.setObject(user, forKey: user.firstName, completion: { _ in })
    storage.setObject(userTwo, forKey: userTwo.firstName, completion: { _ in })
    storage.objects { result in
      switch result {
      case .value(let users):
        XCTAssertEqual(users.count, 2)
        XCTAssertTrue(users.contains(self.user))
        XCTAssertTrue(users.contains(self.userTwo))
        expectation.fulfill()
      default:
        XCTFail()
      }
    }

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
      intStorage.existsObject(forKey: "key-99", completion: { result in
        switch result {
        case .value:
          XCTFail()
        default:
          expectation.fulfill()
        }
      })
    }

    wait(for: [expectation], timeout: 1)
  }
}
