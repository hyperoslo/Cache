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

  func testSetPrimitive() throws {
    try storage.setObject(true, forKey: "bool")
    XCTAssertEqual(try storage.object(forKey: "bool"), true)

    try storage.setObject([true, false, true], forKey: "array of bools")
    XCTAssertEqual(try storage.object(forKey: "array of bools"), [true, false, true])

    try storage.setObject("one", forKey: "string")
    XCTAssertEqual(try storage.object(forKey: "string"), "one")

    try storage.setObject(["one", "two", "three"], forKey: "array of strings")
    XCTAssertEqual(try storage.object(forKey: "array of strings"), ["one", "two", "three"])

    try storage.setObject(10, forKey: "int")
    XCTAssertEqual(try storage.object(forKey: "int"), 10)

    try storage.setObject([1, 2, 3], forKey: "array of ints")
    XCTAssertEqual(try storage.object(forKey: "array of ints"), [1, 2, 3])

    let float: Float = 1.1
    try storage.setObject(float, forKey: "float")
    XCTAssertEqual(try storage.object(forKey: "float"), float)

    let floats: [Float] = [1.1, 1.2, 1.3]
    try storage.setObject(floats, forKey: "array of floats")
    XCTAssertEqual(try storage.object(forKey: "array of floats"), floats)

    let double: Double = 1.1
    try storage.setObject(double, forKey: "double")
    XCTAssertEqual(try storage.object(forKey: "double"), double)

    let doubles: [Double] = [1.1, 1.2, 1.3]
    try storage.setObject(doubles, forKey: "array of doubles")
    XCTAssertEqual(try storage.object(forKey: "array of doubles"), doubles)
  }

  func testSameKey() throws {
    let user = User(firstName: "John", lastName: "Snow")
    let key = "keyMadeOfDragonGlass"
    try storage.setObject(user, forKey: key)
    try storage.setObject("Dragonstone", forKey: key)

    XCTAssertNil(try? storage.object(forKey: key) as User)
    XCTAssertNotNil(try storage.object(forKey: key) as String)
  }
}
