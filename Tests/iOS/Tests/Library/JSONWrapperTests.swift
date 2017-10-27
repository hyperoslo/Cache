import XCTest
import Cache

final class JSONWrapperTests: XCTestCase {
  func testJSONDictionary() {
    let json: JSONDictionary = [
      "name": "John Snow",
      "location": "Winterfell"
    ]

    let wrapper = JSONDictionaryWrapper(jsonDictionary: json)

    let data = try! JSONEncoder().encode(wrapper)
    let decodedWrapper = try! JSONDecoder().decode(JSONDictionaryWrapper.self, from: data)

    XCTAssertEqual(
      NSDictionary(dictionary: decodedWrapper.jsonDictionary),
      NSDictionary(dictionary: json)
    )
  }

  func testJSONArray() {
    let json: JSONArray = [
      [
        "name": "John Snow",
        "location": "Winterfell"
      ],
      [
        "name": "Daenerys Targaryen",
        "location": "Dragonstone"
      ]
    ]

    let wrapper = JSONArrayWrapper(jsonArray: json)

    let data = try! JSONEncoder().encode(wrapper)
    let decodedWrapper = try! JSONDecoder().decode(JSONArrayWrapper.self, from: data)

    zip(json, decodedWrapper.jsonArray).forEach {
      XCTAssertEqual(
        NSDictionary(dictionary: $0),
        NSDictionary(dictionary: $1)
      )
    }
  }
}

