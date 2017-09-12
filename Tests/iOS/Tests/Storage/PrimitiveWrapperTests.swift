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
}

