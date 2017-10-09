import XCTest
import Cache

final class StorageTests: XCTestCase {
  private var storage: Storage!
  let user = User(firstName: "John", lastName: "Snow")

  override func setUp() {
    super.setUp()

    storage = try! Storage(diskConfig: DiskConfig(name: "Thor"), memoryConfig: MemoryConfig())
  }

  override func tearDown() {
    try? storage.removeAll()
    super.tearDown()
  }

  func testSync() throws {
    try storage.setObject(user, forKey: "user")
    let cachedObject = try storage.object(ofType: User.self, forKey: "user")

    XCTAssertEqual(cachedObject, user)
  }

  func testAsync() {
    let expectation = self.expectation(description: #function)
    storage.async.setObject(user, forKey: "user", expiry: nil, completion: { _ in })

    storage.async.object(ofType: User.self, forKey: "user", completion: { result in
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

  func testMigration() {
    struct Person1: Codable {
      let fullName: String
    }

    struct Person2: Codable {
      let firstName: String
      let lastName: String
    }

    // Firstly, save object of type Person1
    let person = Person1(fullName: "John Snow")

    try! storage.setObject(person, forKey: "person")
    XCTAssertNil(try? storage.object(ofType: Person2.self, forKey: "person"))

    // Later, convert to Person2, do the migration, then overwrite
    let tempPerson = try! storage.object(ofType: Person1.self, forKey: "person")
    let parts = tempPerson.fullName.split(separator: " ")
    let migratedPerson = Person2(firstName: String(parts[0]), lastName: String(parts[1]))
    try! storage.setObject(migratedPerson, forKey: "person")

    XCTAssertEqual(
      try! storage.object(ofType: Person2.self, forKey: "person").firstName,
      "John"
    )
  }

  func testSameProperties() {
    struct Person: Codable {
      let firstName: String
      let lastName: String
    }

    struct Alien: Codable {
      let firstName: String
      let lastName: String
    }

    let person = Person(firstName: "John", lastName: "Snow")
    try! storage.setObject(person, forKey: "person")

    // As long as it has same properties, it works too
    let cachedObject = try! storage.object(ofType: Alien.self, forKey: "person")
    XCTAssertEqual(cachedObject.firstName, "John")
  }
}


