import Quick
import Nimble
@testable import Cache

class JSONSpec: QuickSpec {

  override func spec() {
    describe("JSON") {

      describe("#object") {
        it("returns the value") {
          expect(JSON.Array(["Floppy"]).object is [AnyObject]).to(beTrue())
          expect(JSON.Dictionary(["Key": "Value"]).object is [String: AnyObject]).to(beTrue())
        }
      }
    }
  }
}
