import XCTest
@testable import Cache

final class SyncStorageTests: XCTestCase {
  private var storage: SyncStorage!

  override func setUp() {
    super.setUp()
    let memory = MemoryStorage(config: MemoryConfig())
    let disk = try! DiskStorage(config: DiskConfig(name: "Floppy"))
    let hybrid = HybridStorage(memoryStorage: memory, diskStorage: disk)
    let primitive = PrimitiveStorage(storage: hybrid)
    storage = SyncStorage(storage: primitive)
  }

  override func tearDown() {
    try? storage.removeAll()
    super.tearDown()
  }

  func testManyOperations() throws {
    try given("set an initial value") {
      try storage.setObject(0, forKey: "number")
    }

    try when("performs lots of operations") {
      DispatchQueue.concurrentPerform(iterations: 10) { index in
        do {
          let number = try storage.object(forKey: "number") as Int
          let newNumber = number + 1
          try storage.setObject(newNumber, forKey: "number")
        } catch {
          XCTFail()
        }
      }
    }

    wait(for: 5)

    try then("all operation must complete") {
      let number = try storage.object(forKey: "number") as Int
      XCTAssertEqual(number, 10)
    }
  }
}
