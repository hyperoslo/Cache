import Quick
import Nimble
@testable import Cache

class JSONSpec: QuickSpec {

  override func spec() {
    describe("JSON") {

      describe("#object") {
        it("returns the value") {
          expect(JSON.array(["Floppy"]).object is [AnyObject]).to(beTrue())
          expect(JSON.dictionary(["Key": "Value"]).object is [String: AnyObject]).to(beTrue())
        }
      }
    }
  }
}
