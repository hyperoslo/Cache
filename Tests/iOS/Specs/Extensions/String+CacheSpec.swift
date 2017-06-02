import Quick
import Nimble
@testable import Cache

class StringCacheSpec: QuickSpec {

  override func spec() {
    describe("String+Cache") {

      describe("Cachable") {

        describe(".decode") {
          it("decodes from NSData") {
            let string = self.name
            let data = string!.data(using: String.Encoding.utf8)!
            let result = String.decode(data)

            expect(result).to(equal(string))
          }
        }

        describe("#encode") {
          it("encodes to NSData") {
            let string = self.name
            let data = string!.data(using: String.Encoding.utf8)!
            let result = string!.encode()

            expect(result).to(equal(data))
          }
        }
      }
    }
  }
}
