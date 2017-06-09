import XCTest
@testable import Cache

// MARK: - Test case

final class CacheArrayTests: XCTestCase {
  private let fileManager = FileManager()

  /// Test encoding and decoding
  func testDiskStorageWithStringArray() throws {
    let storage = DiskStorage(name: "Storage")
    let array: [String] = ["Test1", "Test2"]

    try storage.addObject(CacheArray(elements: array), forKey: "key")
    let cachedObject: CacheArray<String>? = try storage.object(forKey: "key")

    XCTAssertEqual(cachedObject?.elements.count, 2)
    XCTAssertEqual(cachedObject?.elements[0], "Test1")
    XCTAssertEqual(cachedObject?.elements[1], "Test2")

    // Cleanup
    try fileManager.removeItem(atPath: storage.path)
  }

  /// Test encoding and decoding
  func testDiskStorageWithCodingArray() throws {
    let storage = DiskStorage(name: "Storage")
    let array: [User] = [
      User(firstName: "First1", lastName: "Last1"),
      User(firstName: "First2", lastName: "Last2")
    ]

    try storage.addObject(CacheArray(elements: array), forKey: "key")
    let cachedObject: CacheArray<User>? = try storage.object(forKey: "key")

    XCTAssertEqual(cachedObject?.elements.count, 2)
    XCTAssertEqual(cachedObject?.elements[0].firstName, "First1")
    XCTAssertEqual(cachedObject?.elements[0].lastName, "Last1")
    XCTAssertEqual(cachedObject?.elements[1].firstName, "First2")
    XCTAssertEqual(cachedObject?.elements[1].lastName, "Last2")

    // Cleanup
    try fileManager.removeItem(atPath: storage.path)
  }

  /// Test encoding and decoding
  func testSpecializedCacheWithCodingArray() throws {
    let cache = SpecializedCache<CacheArray<User>>(name: "Cache")
    let array: [User] = [
      User(firstName: "First1", lastName: "Last1"),
      User(firstName: "First2", lastName: "Last2")
    ]

    cache["key"] = CacheArray(elements: array)
    let cachedObject = cache["key"]

    XCTAssertEqual(cachedObject?.elements.count, 2)
    XCTAssertEqual(cachedObject?.elements[0].firstName, "First1")
    XCTAssertEqual(cachedObject?.elements[0].lastName, "Last1")
    XCTAssertEqual(cachedObject?.elements[1].firstName, "First2")
    XCTAssertEqual(cachedObject?.elements[1].lastName, "Last2")

    // Cleanup
    try cache.clear()
  }
}
