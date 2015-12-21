import Quick
import Nimble
@testable import Cache

class JSONCacheSpec: QuickSpec {

  override func spec() {
    describe("JSON+Cache") {

      describe("Cachable") {
        describe(".decode") {
          it("decodes a dictionary from NSData") {
            let object = ["key": "value"]
            let data = try! NSJSONSerialization.dataWithJSONObject(object,
              options: NSJSONWritingOptions())
            let result = JSON.decode(data)!

            switch result {
            case JSON.Dictionary(let dictionary):
              expect(dictionary["key"] is String).to(beTrue())
              expect(dictionary["key"] as? String).to(equal(object["key"]))
            default: break
            }
          }

          it("decodes an array from NSData") {
            let object = ["value1", "value2", "value3"]
            let data = try! NSJSONSerialization.dataWithJSONObject(object,
              options: NSJSONWritingOptions())
            let result = JSON.decode(data)!

            switch result {
            case JSON.Array(let array):
              expect(array is [String]).to(beTrue())
              expect(array.count).to(equal(3))
              expect(array[0] as? String).to(equal(object[0]))
            default: break
            }
          }
        }

        describe("#encode") {
          it("encodes a dictionary to NSData") {
            let object = ["key": "value"]
            let data = try! NSJSONSerialization.dataWithJSONObject(object,
              options: NSJSONWritingOptions())
            let result = JSON.Dictionary(object).encode()

            expect(result).to(equal(data))
          }

          it("encodes an array to NSData") {
            let object = ["value1", "value2", "value3"]
            let data = try! NSJSONSerialization.dataWithJSONObject(object,
              options: NSJSONWritingOptions())
            let result = JSON.Array(object).encode()

            expect(result).to(equal(data))
          }
        }
      }
    }
  }
}
