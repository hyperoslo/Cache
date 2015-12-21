import Quick
import Nimble
@testable import Cache

class CapsuleSpec: QuickSpec {

  override func spec() {
    describe("Capsule") {
      let object = SpecHelper.user
      var capsule: Capsule!

      describe("#expired") {
        it("is not expired") {
          let date = NSDate(timeInterval: 100000, sinceDate: NSDate())
          capsule = Capsule(value: object, expiry: .Date(date))

          expect(capsule.expired).to(beFalse())
        }

        it("is expired") {
          let date = NSDate(timeInterval: -100000, sinceDate: NSDate())
          capsule = Capsule(value: object, expiry: .Date(date))

          expect(capsule.expired).to(beTrue())
        }
      }
    }
  }
}
