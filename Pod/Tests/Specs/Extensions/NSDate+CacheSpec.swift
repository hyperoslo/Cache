import Quick
import Nimble

class NSDateCacheSpec: QuickSpec {

  override func spec() {
    describe("NSDate+Cache") {

      describe("#inThePast") {
        it("returns that date is not in the past") {
          let date = NSDate(timeInterval: 1000, sinceDate: NSDate())
          expect(date.inThePast).to(beFalse())
        }

        it("returns that date is in the past") {
          let date = NSDate(timeInterval: -1000, sinceDate: NSDate())
          expect(date.inThePast).to(beTrue())
        }
      }
    }
  }
}
