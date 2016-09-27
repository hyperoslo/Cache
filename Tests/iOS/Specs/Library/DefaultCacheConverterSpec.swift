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
          let pointer = UnsafeMutablePointer<User>.allocate(capacity: 1)
          (data as NSData).getBytes(pointer, length: data.count)

          let value = pointer.move()
          let result = try! DefaultCacheConverter<User>().decode(data)

          expect(result.firstName).to(equal(value.firstName))
          expect(result.lastName).to(equal(value.lastName))
        }
      }

      describe(".encode") {
        it("decodes string to NSData") {
          let data = withUnsafePointer(to: &object) {
            $0.withMemoryRebound(to: UInt8.self, capacity: 1) { bytes in
              Data(bytes: bytes, count: MemoryLayout.size(ofValue: object))
            }
          }

          let result = try! DefaultCacheConverter<User>().encode(object)

          expect(result).to(equal(data))
        }
      }
    }
  }
}
