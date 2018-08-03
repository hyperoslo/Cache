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

  func testAddObservation() {
    registry.addObservation { _, _ in }
    XCTAssertEqual(registry.observations.count, 1)

    registry.addObservation { _, _ in }
    XCTAssertEqual(registry.observations.count, 2)
  }

  func testRemoveObservation() {
    let token = registry.addObservation { _, _ in }
    XCTAssertEqual(registry.observations.count, 1)

    registry.removeObservation(token: token)
    XCTAssertTrue(registry.observations.isEmpty)
  }

  func testRemoveAllObservation() {
    registry.addObservation { _, _ in }
    registry.addObservation { _, _ in }
    XCTAssertEqual(registry.observations.count, 2)

    registry.removeAllObservations()
    XCTAssertTrue(registry.observations.isEmpty)
  }

  func testNotifyObservers() {
    var change1: StorageChange?
    var change2: StorageChange?

    registry.addObservation { _, change in
      change1 = change
    }

    registry.addObservation { _, change in
      change2 = change
    }

    registry.notifyObservers(about: .addition, in: storage)

    XCTAssertEqual(change1, .addition)
    XCTAssertEqual(change2, .addition)
  }
}
