import XCTest
@testable import Cache

final class StorageSupportTests: XCTestCase {
  private var storage: HybridStorage<String, Bool>!

  override func setUp() {
    super.setUp()
    let memory = MemoryStorage<String, Bool>(config: MemoryConfig())
    let disk = try! DiskStorage<String, Bool>(config: DiskConfig(name: "PrimitiveDisk"), transformer: TransformerFactory.forCodable(ofType: Bool.self))
    storage = HybridStorage<String, Bool>(memoryStorage: memory, diskStorage: disk)
  }

  override func tearDown() {
    try? storage.removeAll()
    super.tearDown()
  }

  func testSetPrimitive() throws {
    do {
      let s = storage.transform(transformer: TransformerFactory.forCodable(ofType: Bool.self))
      try s.setObject(true, forKey: "bool")
      XCTAssertEqual(try s.object(forKey: "bool"), true)
    }

    do {
      let s = storage.transform(transformer: TransformerFactory.forCodable(ofType: [Bool].self))
      try s.setObject([true, false, true], forKey: "array of bools")
      XCTAssertEqual(try s.object(forKey: "array of bools"), [true, false, true])
    }

    do {
      let s = storage.transform(transformer: TransformerFactory.forCodable(ofType: String.self))
      try s.setObject("one", forKey: "string")
      XCTAssertEqual(try s.object(forKey: "string"), "one")
    }

    do {
      let s = storage.transform(transformer: TransformerFactory.forCodable(ofType: [String].self))
      try s.setObject(["one", "two", "three"], forKey: "array of strings")
      XCTAssertEqual(try s.object(forKey: "array of strings"), ["one", "two", "three"])
    }

    do {
      let s = storage.transform(transformer: TransformerFactory.forCodable(ofType: Int.self))
      try s.setObject(10, forKey: "int")
      XCTAssertEqual(try s.object(forKey: "int"), 10)
    }

    do {
      let s = storage.transform(transformer: TransformerFactory.forCodable(ofType: [Int].self))
      try s.setObject([1, 2, 3], forKey: "array of ints")
      XCTAssertEqual(try s.object(forKey: "array of ints"), [1, 2, 3])
    }

    do {
      let s = storage.transform(transformer: TransformerFactory.forCodable(ofType: Float.self))
      let float: Float = 1.1
      try s.setObject(float, forKey: "float")
      XCTAssertEqual(try s.object(forKey: "float"), float)
    }

    do {
      let s = storage.transform(transformer: TransformerFactory.forCodable(ofType: [Float].self))
      let floats: [Float] = [1.1, 1.2, 1.3]
      try s.setObject(floats, forKey: "array of floats")
      XCTAssertEqual(try s.object(forKey: "array of floats"), floats)
    }

    do {
      let s = storage.transform(transformer: TransformerFactory.forCodable(ofType: Double.self))
      let double: Double = 1.1
      try s.setObject(double, forKey: "double")
      XCTAssertEqual(try s.object(forKey: "double"), double)
    }

    do {
      let s = storage.transform(transformer: TransformerFactory.forCodable(ofType: [Double].self))
      let doubles: [Double] = [1.1, 1.2, 1.3]
      try s.setObject(doubles, forKey: "array of doubles")
        XCTAssertEqual(try s.object(forKey: "array of doubles"), doubles)
    }
  }

  func testSetData() {
    let s = storage.transform(transformer: TransformerFactory.forData())

    do {
      let string = "Hello"
      let data = string.data(using: .utf8)!
      try s.setObject(data, forKey: "data")

      let cachedObject = try s.object(forKey: "data")
      let cachedString = String(data: cachedObject, encoding: .utf8)

      XCTAssertEqual(cachedString, string)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }

  func testSetDate() throws {
    let s = storage.transform(transformer: TransformerFactory.forCodable(ofType: Date.self))

    let date = Date(timeIntervalSince1970: 100)
    try s.setObject(date, forKey: "date")
    let cachedObject = try s.object(forKey: "date")

    XCTAssertEqual(date, cachedObject)
  }

  func testSetURL() throws {
    let s = storage.transform(transformer: TransformerFactory.forCodable(ofType: URL.self))
    let url = URL(string: "https://hyper.no")!
    try s.setObject(url, forKey: "url")
    let cachedObject = try s.object(forKey: "url")

    XCTAssertEqual(url, cachedObject)
  }

  func testWithSet() throws {
    let s = storage.transform(transformer: TransformerFactory.forCodable(ofType: Set<Int>.self))
    let set = Set<Int>(arrayLiteral: 1, 2, 3)
    try s.setObject(set, forKey: "set")
    XCTAssertEqual(try s.object(forKey: "set") as Set<Int>, set)
  }

  func testWithSimpleDictionary() throws {
    let s = storage.transform(transformer: TransformerFactory.forCodable(ofType: [String: Int].self))

    let dict: [String: Int] = [
      "key1": 1,
      "key2": 2
    ]

    try s.setObject(dict, forKey: "dict")
    let cachedObject = try s.object(forKey: "dict") as [String: Int]
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

  func testIntFloat() throws {
    let s = storage.transform(transformer: TransformerFactory.forCodable(ofType: Float.self))
    let key = "key"
    try s.setObject(10, forKey: key)

    try then("Casting to int or float is the same") {
      XCTAssertEqual(try s.object(forKey: key), 10)

      let intStorage = s.transform(transformer: TransformerFactory.forCodable(ofType: Int.self))
      XCTAssertEqual(try intStorage.object(forKey: key), 10)
    }
  }

  func testFloatDouble() throws {
    let s = storage.transform(transformer: TransformerFactory.forCodable(ofType: Float.self))
    let key = "key"
    try s.setObject(10.5, forKey: key)

    try then("Casting to float or double is the same") {
      XCTAssertEqual(try s.object(forKey: key), 10.5)

      let doubleStorage = s.transform(transformer: TransformerFactory.forCodable(ofType: Double.self))
      XCTAssertEqual(try doubleStorage.object(forKey: key), 10.5)
    }
  }

  func testCastingToAnotherType() throws {
    let s = storage.transform(transformer: TransformerFactory.forCodable(ofType: String.self))
    try s.setObject("Hello", forKey: "string")

    do {
      let intStorage = s.transform(transformer: TransformerFactory.forCodable(ofType: Int.self))
      let _ = try intStorage.object(forKey: "string")
      XCTFail()
    } catch {
      XCTAssertTrue(error is DecodingError)
    }
  }

  func testOverridenOnDisk() throws {
    let intStorage = storage.transform(transformer: TransformerFactory.forCodable(ofType: Int.self))
    let stringStorage = storage.transform(transformer: TransformerFactory.forCodable(ofType: String.self))

    let key = "sameKey"

    try intStorage.setObject(1, forKey: key)
    try stringStorage.setObject("hello world", forKey: key)

    let intValue = try? intStorage.diskStorage.object(forKey: key)
    let stringValue = try? stringStorage.diskStorage.object(forKey: key)

    XCTAssertNil(intValue)
    XCTAssertNotNil(stringValue)
  }
}
