import XCTest
@testable import Cache

final class StorageObservationRegistryTests: XCTestCase {
  private var registry: StorageObservationRegistry<Storage<User>>!
  private var storage: Storage<User>!

  override func setUp() {
    super.setUp()
    registry = StorageObservationRegistry()
    storage = try! Storage<User>(
      diskConfig: DiskConfig(name: "Thor"),
      memoryConfig: MemoryConfig(),
      transformer: TransformerFactory.forCodable(ofType: User.self)
    )
  }

  func testRegister() {
    registry.register { _, _ in }
    XCTAssertEqual(registry.observations.count, 1)

    registry.register { _, _ in }
    XCTAssertEqual(registry.observations.count, 2)
  }

  func testDeregister() {
    let token = registry.register { _, _ in }
    XCTAssertEqual(registry.observations.count, 1)

    registry.deregister(token: token)
    XCTAssertTrue(registry.observations.isEmpty)
  }

  func testDeregisterAll() {
    registry.register { _, _ in }
    registry.register { _, _ in }
    XCTAssertEqual(registry.observations.count, 2)

    registry.deregisterAll()
    XCTAssertTrue(registry.observations.isEmpty)
  }

  func testNotifyObservers() {
    var change1: StorageChange?
    var change2: StorageChange?

    registry.register { _, change in
      change1 = change
    }

    registry.register { _, change in
      change2 = change
    }

    registry.notifyObservers(about: .addition, in: storage)

    XCTAssertEqual(change1, .addition)
    XCTAssertEqual(change2, .addition)
  }
}
