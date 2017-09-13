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

  func testWithSet() throws {
    let set = Set<Int>(arrayLiteral: 1, 2, 3)
    try storage.setObject(set, forKey: "set")
    XCTAssertEqual(try storage.object(forKey: "set") as Set<Int>, set)
  }

  func testWithSimpleDictionary() throws {
    let dict: [String: Int] = [
      "key1": 1,
      "key2": 2
    ]

    try then("can't save dictionary") {
      do {
        try storage.setObject(dict, forKey: "dict")
        let cachedObject = try storage.object(forKey: "key") as [String: Int]
        XCTAssertEqual(cachedObject, dict)
      } catch {
        XCTAssertTrue(error.localizedDescription.contains("no such file"))
      }
    }
  }

  func testSameKey() throws {
    let user = User(firstName: "John", lastName: "Snow")
    let key = "keyMadeOfDragonGlass"
    try storage.setObject(user, forKey: key)
    try storage.setObject("Dragonstone", forKey: key)

    XCTAssertNil(try? storage.object(forKey: key) as User)
    XCTAssertNotNil(try storage.object(forKey: key) as String)
  }

  func testIntFloat() throws {
    let key = "key"
    try storage.setObject(10, forKey: key)

    try then("Casting to int or float is the same") {
      XCTAssertEqual(try storage.object(forKey: key) as Int, 10)
      XCTAssertEqual(try storage.object(forKey: key) as Float, 10)
    }
  }

  func testFloatDouble() throws {
    let key = "key"
    try storage.setObject(10.5, forKey: key)

    try then("Casting to float or double is the same") {
      XCTAssertEqual(try storage.object(forKey: key) as Float, 10.5)
      XCTAssertEqual(try storage.object(forKey: key) as Double, 10.5)
    }
  }

  func testCastingToAnotherType() throws {
    try storage.setObject("Hello", forKey: "string")

    do {
      let cachedObject = try storage.object(forKey: "string") as Int
      XCTAssertEqual(cachedObject, 10)
    } catch {
      XCTAssertTrue(error is DecodingError)
    }
  }
}
