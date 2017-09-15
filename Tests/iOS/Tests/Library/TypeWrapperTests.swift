import XCTest
@testable import Cache

final class TypeWrapperTests: XCTestCase {
  func testString() {
    let value = "Hello"
    let wrapper = TypeWrapper(object: value)

    let data = try! JSONEncoder().encode(wrapper)
    let anotherWrapper = try! JSONDecoder().decode(TypeWrapper<String>.self, from: data)

    XCTAssertEqual(value, anotherWrapper.object)
  }

  func testInt() {
    let value = 10
    let wrapper = TypeWrapper(object: value)

    let data = try! JSONEncoder().encode(wrapper)
    let anotherWrapper = try! JSONDecoder().decode(TypeWrapper<Int>.self, from: data)

    XCTAssertEqual(value, anotherWrapper.object)
  }

  func testDate() {
    let value = Date()
    let wrapper = TypeWrapper(object: value)

    let data = try! JSONEncoder().encode(wrapper)
    let anotherWrapper = try! JSONDecoder().decode(TypeWrapper<Date>.self, from: data)

    XCTAssertEqual(value, anotherWrapper.object)
  }

  func testBool() {
    let value = true
    let wrapper = TypeWrapper(object: value)

    let data = try! JSONEncoder().encode(wrapper)
    let anotherWrapper = try! JSONDecoder().decode(TypeWrapper<Bool>.self, from: data)

    XCTAssertEqual(value, anotherWrapper.object)
  }

  func testData() {
    let value = "Hello".data(using: .utf8)!
    let wrapper = TypeWrapper(object: value)

    let data = try! JSONEncoder().encode(wrapper)
    let anotherWrapper = try! JSONDecoder().decode(TypeWrapper<Data>.self, from: data)

    XCTAssertEqual(value, anotherWrapper.object)
  }

  func testArray() {
    let value = [1, 2, 3]
    let wrapper = TypeWrapper(object: value)

    let data = try! JSONEncoder().encode(wrapper)
    let anotherWrapper = try! JSONDecoder().decode(TypeWrapper<Array<Int>>.self, from: data)

    XCTAssertEqual(value, anotherWrapper.object)
  }

  func testDictionary() {
    let value = [
      "key1": 1,
      "key2": 2
    ]

    let wrapper = TypeWrapper(object: value)

    let data = try! JSONEncoder().encode(wrapper)
    let anotherWrapper = try! JSONDecoder().decode(TypeWrapper<Dictionary<String, Int>>.self, from: data)

    XCTAssertEqual(value, anotherWrapper.object)
  }

  func testSet() {
    let value = Set(arrayLiteral: 1, 2, 3)
    let wrapper = TypeWrapper(object: value)

    let data = try! JSONEncoder().encode(wrapper)
    let anotherWrapper = try! JSONDecoder().decode(TypeWrapper<Set<Int>>.self, from: data)

    XCTAssertEqual(value, anotherWrapper.object)
  }
}

