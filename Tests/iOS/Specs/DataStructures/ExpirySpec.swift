import Quick
import Nimble
@testable import Cache

class ExpirySpec: QuickSpec {

  override func spec() {
    describe("Expiry") {
      var expiry: Expiry!

      describe("#date") {
        it("returns date in the distant future") {
          let date = NSDate(timeIntervalSince1970: 60 * 60 * 24 * 365 * 68)
          expiry = .Never

          expect(expiry.date).to(equal(date))
        }

        it("returns date by adding time interval") {
          let date = NSDate().dateByAddingTimeInterval(1000)
          expiry = .Seconds(1000)

          expect(expiry.date.timeIntervalSince1970).to(beCloseTo(date.timeIntervalSince1970, within: 0.01))
        }

        it("returns specified date") {
          let date = NSDate().dateByAddingTimeInterval(1000)
          expiry = .Date(date)

          expect(expiry.date).to(equal(date))
        }
      }
    }
  }
}
