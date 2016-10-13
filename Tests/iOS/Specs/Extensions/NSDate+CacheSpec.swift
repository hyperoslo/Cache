import Quick
import Nimble
@testable import Cache

class NSDateCacheSpec: QuickSpec {

  override func spec() {
    describe("NSDate+Cache") {

      describe("#inThePast") {
        it("returns that date is not in the past") {
          let date = Date(timeInterval: 100000, since: Date())

          expect(date.inThePast).to(beFalse())
        }

        it("returns that date is in the past") {
          let date = Date(timeInterval: -100000, since: Date())

          expect(date.inThePast).to(beTrue())
        }
      }

      describe("Cachable") {
        describe(".decode") {
          it("decodes from NSData") {
            let date = Date()
            let data = NSKeyedArchiver.archivedData(withRootObject: date)
            let result = Date.decode(data)

            expect(result).to(equal(date))
          }
        }

        describe("#encode") {
          it("encodes to NSData") {
            let date = Date()
            let data = NSKeyedArchiver.archivedData(withRootObject: date)
            let result = data.encode()

            expect(result).to(equal(data))
          }
        }
      }
    }
  }
}
