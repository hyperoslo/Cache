import Quick
import Nimble
@testable import Cache

class NSDataCacheSpec: QuickSpec {

  override func spec() {
    describe("NSData+Cache") {

      describe("Cachable") {
        describe(".decode") {
          it("decodes from NSData") {
            let data = SpecHelper.data(64)
            let result = NSData.decode(data)

            expect(result).to(equal(data))
          }
        }

        describe("#encode") {
          it("encodes to NSData") {
            let data = SpecHelper.data(64)
            let result = data.encode()

            expect(result).to(equal(data))
          }
        }
      }
    }
  }
}
