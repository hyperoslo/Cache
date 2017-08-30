//
//  MacTests.swift
//  Cache
//
//  Created by Filip Klembara on 8/30/17.
//

import XCTest
@testable import Cache

class MacTests: XCTestCase {

    func testExample() {
        let cache = SpecializedCache<String>(name: "StringCache")
        XCTAssertNoThrow(try cache.clear(keepingRootDirectory: true))
        XCTAssertNil(cache.object(forKey: "A"))
        XCTAssertNoThrow(try cache.addObject("B", forKey: "A"))
        XCTAssert(cache.object(forKey: "A") == "B")
        XCTAssertNoThrow(try cache.clear())
    }

    static var allTests = [
        ("testExample", testExample),
        ]
}
