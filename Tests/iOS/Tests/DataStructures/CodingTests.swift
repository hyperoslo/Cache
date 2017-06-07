import XCTest
@testable import Cache

// MARK: - Test case

final class CodingTests: XCTestCase {
  private var storage: DiskStorage!
  private let fileManager = FileManager()
  private let key = "post"
  private var object: User!

  override func setUp() {
    super.setUp()
    storage = DiskStorage(name: "Storage")
    object = User(firstName: "First", lastName: "Last")
  }

  override func tearDown() {
    try? fileManager.removeItem(atPath: storage.path)
    super.tearDown()
  }

  /// Test encoding and decoding
  func testCoding() {
    try! storage.addObject(object, forKey: key)
    let cachedObject: User? = try! storage.object(forKey: key)
    XCTAssertEqual(cachedObject?.firstName, "First")
    XCTAssertEqual(cachedObject?.lastName, "Last")
  }
}
