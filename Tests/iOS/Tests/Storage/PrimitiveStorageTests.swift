import XCTest
@testable import Cache

final class PrimitiveStorageTests: XCTestCase {
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

  func testPrimitiveCheck() {
    XCTAssertTrue(storage.isPrimitive(type: UIImage.self))
    XCTAssertTrue(storage.isPrimitive(type: Bool.self))
    XCTAssertTrue(storage.isPrimitive(type: [Bool].self))
    XCTAssertTrue(storage.isPrimitive(type: String.self))
    XCTAssertTrue(storage.isPrimitive(type: [String].self))
    XCTAssertTrue(storage.isPrimitive(type: Int.self))
    XCTAssertTrue(storage.isPrimitive(type: [Int].self))
    XCTAssertTrue(storage.isPrimitive(type: Float.self))
    XCTAssertTrue(storage.isPrimitive(type: [Float].self))
    XCTAssertTrue(storage.isPrimitive(type: Double.self))
    XCTAssertTrue(storage.isPrimitive(type: [Double].self))
  }
}
