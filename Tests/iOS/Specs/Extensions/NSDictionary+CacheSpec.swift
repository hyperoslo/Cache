import Quick
import Nimble
@testable import Cache

extension NSDictionary: Cachable {}

class NSDictionaryCacheSpec: QuickSpec {
  override func spec() {
    describe("NSDictionary+Cache") {
      describe("Cachable") {
        describe(".decode") {
          it("decodes from Data") {
            let dictionary = NSDictionary(dictionary: ["key": "value"])
            let data = NSKeyedArchiver.archivedData(withRootObject: dictionary)
            let result = NSDictionary.decode(data)

            expect(result).to(equal(dictionary))
          }
        }

        describe("#encode") {
          it("encodes to Data") {
            let dictionary = NSDictionary(dictionary: ["key": "value"])
            let data = NSKeyedArchiver.archivedData(withRootObject: dictionary)
            let result = data.encode()

            expect(result).to(equal(data))
          }
        }
      }
    }
  }
}
