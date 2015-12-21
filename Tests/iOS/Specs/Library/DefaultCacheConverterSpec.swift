import Quick
import Nimble
@testable import Cache

class DefaultCacheConverterSpec: QuickSpec {

  override func spec() {
    describe("DefaultCacheConverter") {
      var object = SpecHelper.user

      describe(".decode") {
        it("decodes string to NSData") {
          let data = object.encode()!
          let pointer = UnsafeMutablePointer<User>.alloc(1)
          data.getBytes(pointer, length: data.length)

          let value = pointer.move()
          let result = try! DefaultCacheConverter<User>().decode(data)

          expect(result.firstName).to(equal(value.firstName))
          expect(result.lastName).to(equal(value.lastName))
        }
      }

      describe(".encode") {
        it("decodes string to NSData") {
          let data = withUnsafePointer(&object) { p in
            NSData(bytes: p, length: sizeofValue(object))
          }
          let result = try! DefaultCacheConverter<User>().encode(object)

          expect(result).to(equal(data))
        }
      }
    }
  }
}
