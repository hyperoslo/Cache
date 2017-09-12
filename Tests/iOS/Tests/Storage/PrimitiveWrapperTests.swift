import XCTest
@testable import Cache

final class PrimitiveWrapperTests: XCTestCase {
  func testString() {
    let value = "Hello"
    let wrapper = PrimitiveWrapper(value: value)

    let data = try! JSONEncoder().encode(wrapper)
    let anotherWrapper = try! JSONDecoder().decode(PrimitiveWrapper<String>.self, from: data)

    XCTAssertEqual(value, anotherWrapper.value)
  }

  func testInt() {
    let value = 10
    let wrapper = PrimitiveWrapper(value: value)

    let data = try! JSONEncoder().encode(wrapper)
    let anotherWrapper = try! JSONDecoder().decode(PrimitiveWrapper<Int>.self, from: data)

    XCTAssertEqual(value, anotherWrapper.value)
  }

  func testDate() {
    let value = Date()
    let wrapper = PrimitiveWrapper(value: value)

    let data = try! JSONEncoder().encode(wrapper)
    let anotherWrapper = try! JSONDecoder().decode(PrimitiveWrapper<Date>.self, from: data)

    XCTAssertEqual(value, anotherWrapper.value)
  }

  func testBool() {
    let value = true
    let wrapper = PrimitiveWrapper(value: value)

    let data = try! JSONEncoder().encode(wrapper)
    let anotherWrapper = try! JSONDecoder().decode(PrimitiveWrapper<Bool>.self, from: data)

    XCTAssertEqual(value, anotherWrapper.value)
  }

  func testData() {
    let value = "Hello".data(using: .utf8)!
    let wrapper = PrimitiveWrapper(value: value)

    let data = try! JSONEncoder().encode(wrapper)
    let anotherWrapper = try! JSONDecoder().decode(PrimitiveWrapper<Data>.self, from: data)

    XCTAssertEqual(value, anotherWrapper.value)
  }

  func testArray() {
    let value = [1, 2, 3]
    let wrapper = PrimitiveWrapper(value: value)

    let data = try! JSONEncoder().encode(wrapper)
    let anotherWrapper = try! JSONDecoder().decode(PrimitiveWrapper<Array<Int>>.self, from: data)

    XCTAssertEqual(value, anotherWrapper.value)
  }

  func testDictionary() {
    let value = [
      "key1": 1,
      "key2": 2
    ]

    let wrapper = PrimitiveWrapper(value: value)

    let data = try! JSONEncoder().encode(wrapper)
    let anotherWrapper = try! JSONDecoder().decode(PrimitiveWrapper<Dictionary<String, Int>>.self, from: data)

    XCTAssertEqual(value, anotherWrapper.value)
  }

  func testSet() {
    let value = Set(arrayLiteral: 1, 2, 3)
    let wrapper = PrimitiveWrapper(value: value)

    let data = try! JSONEncoder().encode(wrapper)
    let anotherWrapper = try! JSONDecoder().decode(PrimitiveWrapper<Set<Int>>.self, from: data)

    XCTAssertEqual(value, anotherWrapper.value)
  }
}

