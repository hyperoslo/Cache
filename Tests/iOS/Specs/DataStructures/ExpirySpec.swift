import Quick
import Nimble
@testable import Cache

class ExpirySpec: QuickSpec {

  override func spec() {
    describe("Expiry") {
      var expiry: Expiry!

      describe("#date") {
        it("returns date in the distant future") {
          let date = Date(timeIntervalSince1970: 60 * 60 * 24 * 365 * 68)
          expiry = .never

          expect(expiry.date).to(equal(date))
        }

        it("returns date by adding time interval") {
          let date = Date().addingTimeInterval(1000)
          expiry = .seconds(1000)

          expect(expiry.date.timeIntervalSince1970) ≈ (date.timeIntervalSince1970, 0.01)
        }

        it("returns specified date") {
          let date = Date().addingTimeInterval(1000)
          expiry = .date(date)

          expect(expiry.date).to(equal(date))
        }
      }
    }
  }
}
