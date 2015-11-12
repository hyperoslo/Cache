import Quick
import Nimble

class CapsuleSpec: QuickSpec {

  override func spec() {
    describe("Capsule") {
      let object = User(firstName: "John", lastName: "Snow")
      var capsule: Capsule!

      describe("#expired") {
        it("is not expired") {
          let date = NSDate(timeInterval: 1000, sinceDate: NSDate())
          capsule = Capsule(value: object, expiry: .Date(date))
          expect(capsule.expired).to(beFalse())
        }

        it("is expired") {
          let date = NSDate(timeInterval: -1000, sinceDate: NSDate())
          capsule = Capsule(value: object, expiry: .Date(date))
          expect(capsule.expired).to(beTrue())
        }
      }
    }
  }
}
