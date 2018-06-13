import XCTest
import Cache

final class StorageTests: XCTestCase {
  private var storage: Storage<User>!
  let user = User(firstName: "John", lastName: "Snow")

  override func setUp() {
    super.setUp()

    storage = try! Storage<User>(
      diskConfig: DiskConfig(name: "Thor"),
      memoryConfig: MemoryConfig(),
      transformer: TransformerFactory.forCodable(ofType: User.self)
    )
  }

  override func tearDown() {
    try? storage.removeAll()
    super.tearDown()
  }

  func testSync() throws {
    try storage.setObject(user, forKey: "user")
    let cachedObject = try storage.object(forKey: "user")

    XCTAssertEqual(cachedObject, user)
  }

  func testAsync() {
    let expectation = self.expectation(description: #function)
    storage.async.setObject(user, forKey: "user", expiry: nil, completion: { _ in })

    storage.async.object(forKey: "user", completion: { result in
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

    let person1Storage = storage.transformCodable(ofType: Person1.self)
    let person2Storage = storage.transformCodable(ofType: Person2.self)

    // Firstly, save object of type Person1
    let person = Person1(fullName: "John Snow")

    try! person1Storage.setObject(person, forKey: "person")
    XCTAssertNil(try? person2Storage.object(forKey: "person"))

    // Later, convert to Person2, do the migration, then overwrite
    let tempPerson = try! person1Storage.object(forKey: "person")
    let parts = tempPerson.fullName.split(separator: " ")
    let migratedPerson = Person2(firstName: String(parts[0]), lastName: String(parts[1]))
    try! person2Storage.setObject(migratedPerson, forKey: "person")

    XCTAssertEqual(
      try! person2Storage.object(forKey: "person").firstName,
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

    let personStorage = storage.transformCodable(ofType: Person.self)
    let alienStorage = storage.transformCodable(ofType: Alien.self)

    let person = Person(firstName: "John", lastName: "Snow")
    try! personStorage.setObject(person, forKey: "person")

    // As long as it has same properties, it works too
    let cachedObject = try! alienStorage.object(forKey: "person")
    XCTAssertEqual(cachedObject.firstName, "John")
  }
}
