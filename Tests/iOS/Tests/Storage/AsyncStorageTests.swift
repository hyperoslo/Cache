import XCTest
@testable import Cache

final class AsyncStorageTests: XCTestCase {
  private var storage: AsyncStorage!

  override func setUp() {
    super.setUp()
    let memory = MemoryStorage(config: MemoryConfig())
    let disk = try! DiskStorage(config: DiskConfig(name: "Floppy"))
    let hybrid = HybridStorage(memoryStorage: memory, diskStorage: disk)
    storage = AsyncStorage(storage: hybrid)
  }

  override func tearDown() {
    storage.removeAll(completion: { _ in })
    super.tearDown()
  }
}

