import XCTest
@testable import Cache

final class StorageTests: XCTestCase {
  private var storage: Storage<String, User>!
  let user = User(firstName: "John", lastName: "Snow")

  override func setUp() {
    super.setUp()

    storage = try! Storage<String, User>(
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

  // MARK: - Storage observers

  func testAddStorageObserver() throws {
    var changes = [StorageChange<String>]()
    var observer: ObserverMock? = ObserverMock()

    storage.addStorageObserver(observer!) { _, _, change in
      changes.append(change)
    }

    try storage.setObject(user, forKey: "user1")
    try storage.setObject(user, forKey: "user2")
    try storage.removeObject(forKey: "user1")
    try storage.removeExpiredObjects()
    try storage.removeAll()
    observer = nil
    try storage.setObject(user, forKey: "user1")

    let expectedChanges: [StorageChange<String>] = [
      .add(key: "user1"),
      .add(key: "user2"),
      .remove(key: "user1"),
      .removeExpired,
      .removeAll
    ]

    XCTAssertEqual(changes, expectedChanges)
  }

  func testRemoveAllStorageObservers() throws {
    var changes1 = [StorageChange<String>]()
    var changes2 = [StorageChange<String>]()

    storage.addStorageObserver(self) { _, _, change in
      changes1.append(change)
    }

    storage.addStorageObserver(self) { _, _, change in
      changes2.append(change)
    }

    try storage.setObject(user, forKey: "user1")
    XCTAssertEqual(changes1, [StorageChange.add(key: "user1")])
    XCTAssertEqual(changes2, [StorageChange.add(key: "user1")])

    changes1.removeAll()
    changes2.removeAll()
    storage.removeAllStorageObservers()

    try storage.setObject(user, forKey: "user1")
    XCTAssertTrue(changes1.isEmpty)
    XCTAssertTrue(changes2.isEmpty)
  }

  // MARK: - Key observers

  func testAddObserverForKey() throws {
    var changes = [KeyChange<User>]()
    storage.addObserver(self, forKey: "user1") { _, _, change in
      changes.append(change)
    }

    storage.addObserver(self, forKey: "user2") { _, _, change in
      changes.append(change)
    }

    try storage.setObject(user, forKey: "user1")
    XCTAssertEqual(changes, [KeyChange.edit(before: nil, after: user)])
  }

  func testKeyObserverWithRemoveExpired() throws {
    var changes = [KeyChange<User>]()
    storage.addObserver(self, forKey: "user1") { _, _, change in
      changes.append(change)
    }

    storage.addObserver(self, forKey: "user2") { _, _, change in
      changes.append(change)
    }

    try storage.setObject(user, forKey: "user1", expiry: Expiry.seconds(-1000))
    try storage.removeExpiredObjects()

    XCTAssertEqual(changes, [.edit(before: nil, after: user), .remove])
  }

  func testKeyObserverWithRemoveAll() throws {
    var changes1 = [KeyChange<User>]()
    var changes2 = [KeyChange<User>]()

    storage.addObserver(self, forKey: "user1") { _, _, change in
      changes1.append(change)
    }

    storage.addObserver(self, forKey: "user2") { _, _, change in
      changes2.append(change)
    }

    try storage.setObject(user, forKey: "user1")
    try storage.setObject(user, forKey: "user2")
    try storage.removeAll()

    XCTAssertEqual(changes1, [.edit(before: nil, after: user), .remove])
    XCTAssertEqual(changes2, [.edit(before: nil, after: user), .remove])
  }

  func testRemoveKeyObserver() throws {
    var changes = [KeyChange<User>]()

    // Test remove
    storage.addObserver(self, forKey: "user1") { _, _, change in
      changes.append(change)
    }

    storage.removeObserver(forKey: "user1")
    try storage.setObject(user, forKey: "user1")
    XCTAssertTrue(changes.isEmpty)

    // Test remove by token
    let token = storage.addObserver(self, forKey: "user2") { _, _, change in
      changes.append(change)
    }

    token.cancel()
    try storage.setObject(user, forKey: "user1")
    XCTAssertTrue(changes.isEmpty)
  }

  func testRemoveAllKeyObservers() throws {
    var changes1 = [KeyChange<User>]()
    var changes2 = [KeyChange<User>]()

    storage.addObserver(self, forKey: "user1") { _, _, change in
      changes1.append(change)
    }

    storage.addObserver(self, forKey: "user2") { _, _, change in
      changes2.append(change)
    }

    try storage.setObject(user, forKey: "user1")
    try storage.setObject(user, forKey: "user2")
    XCTAssertEqual(changes1, [KeyChange.edit(before: nil, after: user)])
    XCTAssertEqual(changes2, [KeyChange.edit(before: nil, after: user)])

    changes1.removeAll()
    changes2.removeAll()
    storage.removeAllKeyObservers()

    try storage.setObject(user, forKey: "user1")
    XCTAssertTrue(changes1.isEmpty)
    XCTAssertTrue(changes2.isEmpty)
  }
}

private class ObserverMock {}
