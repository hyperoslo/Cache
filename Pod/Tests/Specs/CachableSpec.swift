import Quick
import Nimble

class CachableSpec: QuickSpec {

  override func spec() {
    describe("Cachable") {

      var object = User(firstName: "John", lastName: "Snow")

      describe("#encode") {
        it("returns the correct encoded object data") {
          let data = withUnsafePointer(&object) { p in
            NSData(bytes: p, length: sizeofValue(object))
          }

          expect(object.encode()).to(equal(data))
        }
      }

      describe(".decode") {
        it("returns the correct decoded object") {
          let data = object.encode()
          let user = User.decode(data)

          expect(object.firstName).to(equal(user.firstName))
          expect(object.lastName).to(equal(user.lastName))
        }
      }
    }
  }
}
