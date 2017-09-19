import XCTest
@testable import Cache

final class TypeWrapperStorageTests: XCTestCase {
  private var storage: TypeWrapperStorage!

  override func setUp() {
    super.setUp()
    let memory = MemoryStorage(config: MemoryConfig())
    let disk = try! DiskStorage(config: DiskConfig(name: "PrimitiveDisk"))
    let hybrid = HybridStorage(memoryStorage: memory, diskStorage: disk)
    storage = TypeWrapperStorage(storage: hybrid)
  }

  override func tearDown() {
    try? storage.removeAll()
    super.tearDown()
  }

  func testSetPrimitive() throws {
    try storage.setObject(true, forKey: "bool")
    XCTAssertEqual(try storage.object(ofType: Bool.self, forKey: "bool"), true)

    try storage.setObject([true, false, true], forKey: "array of bools")
    XCTAssertEqual(try storage.object(ofType: [Bool].self, forKey: "array of bools"), [true, false, true])

    try storage.setObject("one", forKey: "string")
    XCTAssertEqual(try storage.object(ofType: String.self, forKey: "string"), "one")

    try storage.setObject(["one", "two", "three"], forKey: "array of strings")
    XCTAssertEqual(try storage.object(ofType: [String].self, forKey: "array of strings"), ["one", "two", "three"])

    try storage.setObject(10, forKey: "int")
    XCTAssertEqual(try storage.object(ofType: Int.self, forKey: "int"), 10)

    try storage.setObject([1, 2, 3], forKey: "array of ints")
    XCTAssertEqual(try storage.object(ofType: [Int].self, forKey: "array of ints"), [1, 2, 3])

    let float: Float = 1.1
    try storage.setObject(float, forKey: "float")
    XCTAssertEqual(try storage.object(ofType: Float.self, forKey: "float"), float)

    let floats: [Float] = [1.1, 1.2, 1.3]
    try storage.setObject(floats, forKey: "array of floats")
    XCTAssertEqual(try storage.object(ofType: [Float].self, forKey: "array of floats"), floats)

    let double: Double = 1.1
    try storage.setObject(double, forKey: "double")
    XCTAssertEqual(try storage.object(ofType: Double.self, forKey: "double"), double)

    let doubles: [Double] = [1.1, 1.2, 1.3]
    try storage.setObject(doubles, forKey: "array of doubles")
    XCTAssertEqual(try storage.object(ofType: [Double].self, forKey: "array of doubles"), doubles)
  }

  func testSetData() {
    do {
      let string = "Hello"
      let data = string.data(using: .utf8)
      try storage.setObject(data, forKey: "data")

      let cachedObject = try storage.object(ofType: Data.self, forKey: "data")
      let cachedString = String(data: cachedObject, encoding: .utf8)

      XCTAssertEqual(cachedString, string)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }

  func testSetDate() throws {
    let date = Date(timeIntervalSince1970: 100)
    try storage.setObject(date, forKey: "date")
    let cachedObject = try storage.object(ofType: Date.self, forKey: "date")

    XCTAssertEqual(date, cachedObject)
  }

  func testSetURL() throws {
    let url = URL(string: "https://hyper.no")
    try storage.setObject(url, forKey: "url")
    let cachedObject = try storage.object(ofType: URL.self, forKey: "url")

    XCTAssertEqual(url, cachedObject)
  }

  func testWithSet() throws {
    let set = Set<Int>(arrayLiteral: 1, 2, 3)
    try storage.setObject(set, forKey: "set")
    XCTAssertEqual(try storage.object(ofType: Set<Int>.self, forKey: "set") as Set<Int>, set)
  }

  func testWithSimpleDictionary() throws {
    let dict: [String: Int] = [
      "key1": 1,
      "key2": 2
    ]

    try storage.setObject(dict, forKey: "dict")
    let cachedObject = try storage.object(ofType: [String: Int].self, forKey: "dict") as [String: Int]
    XCTAssertEqual(cachedObject, dict)
  }

  func testWithComplexDictionary() {
    let _: [String: Any] = [
      "key1": 1,
      "key2": 2
    ]

    // fatal error: Dictionary<String, Any> does not conform to Encodable because Any does not conform to Encodable
    // try storage.setObject(dict, forKey: "dict")
  }

  func testSameKey() throws {
    let user = User(firstName: "John", lastName: "Snow")
    let key = "keyMadeOfDragonGlass"
    try storage.setObject(user, forKey: key)
    try storage.setObject("Dragonstone", forKey: key)

    XCTAssertNil(try? storage.object(ofType: User.self, forKey: key))
    XCTAssertNotNil(try storage.object(ofType: String.self, forKey: key))
  }

  func testIntFloat() throws {
    let key = "key"
    try storage.setObject(10, forKey: key)

    try then("Casting to int or float is the same") {
      XCTAssertEqual(try storage.object(ofType: Int.self, forKey: key), 10)
      XCTAssertEqual(try storage.object(ofType: Float.self, forKey: key), 10)
    }
  }

  func testFloatDouble() throws {
    let key = "key"
    try storage.setObject(10.5, forKey: key)

    try then("Casting to float or double is the same") {
      XCTAssertEqual(try storage.object(ofType: Float.self, forKey: key), 10.5)
      XCTAssertEqual(try storage.object(ofType: Double.self, forKey: key), 10.5)
    }
  }

  func testCastingToAnotherType() throws {
    try storage.setObject("Hello", forKey: "string")

    do {
      let cachedObject = try storage.object(ofType: Int.self, forKey: "string")
      XCTAssertEqual(cachedObject, 10)
    } catch {
      XCTAssertTrue(error is DecodingError)
    }
  }
}
