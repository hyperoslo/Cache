import Quick
import Nimble

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
    }
  }
}
