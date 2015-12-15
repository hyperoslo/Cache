import Quick
import Nimble
@testable import Cache

class StringCacheSpec: QuickSpec {

  override func spec() {
    describe("String+Cache") {

      describe("#base64") {
        it("returns the correct base64 string") {
          let items = [
            "John Snow": "Sm9obiBTbm93",
            "You know nothing": "WW91IGtub3cgbm90aGluZw==",
            "Night's Watch": "TmlnaHQncyBXYXRjaA=="
          ]

          for (key, value) in items {
            expect(key.base64()).to(equal(value))
          }
        }
      }

      describe("Cachable") {

        describe(".decode") {
          it("decodes from NSData") {
            let string = self.name
            let data = string.dataUsingEncoding(NSUTF8StringEncoding)!
            let result = String.decode(data)

            expect(result).to(equal(string))
          }
        }

        describe("#encode") {
          it("encodes to NSData") {
            let string = self.name
            let data = string.dataUsingEncoding(NSUTF8StringEncoding)!
            let result = string.encode()

            expect(result).to(equal(data))
          }
        }
      }
    }
  }
}
