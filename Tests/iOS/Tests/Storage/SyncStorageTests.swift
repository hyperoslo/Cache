import XCTest
@testable import Cache

final class SyncStorageTests: XCTestCase {
  private var storage: PrimitiveStorage!

  override func setUp() {
    super.setUp()
    let memory = MemoryStorage(config: MemoryConfig())
    let disk = try! DiskStorage(config: DiskConfig(name: "Floppy"))
    let hybrid = HybridStorage(memoryStorage: memory, diskStorage: disk)
    storage = PrimitiveStorage(storage: hybrid)
  }

  override func tearDown() {
    try? storage.removeAll()
    super.tearDown()
  }
}
