import Quick
import Nimble
@testable import Cache

class UIImageCacheSpec: QuickSpec {

  override func spec() {
    describe("UIImage+Cache") {
      describe("Cachable") {
        describe(".decode") {
          it("decodes from NSData") {
            let image = SpecHelper.image()
            let data = image.encode()!
            let result = UIImage.decode(data)!

            expect(result.isEqualToImage(image)).to(beTrue())
          }
        }

        describe("#encode") {
          it("encodes to NSData") {
            let image = SpecHelper.image()
            let data = UIImagePNGRepresentation(image)
            let result = image.encode()!

            expect(result).to(equal(data))
          }
        }
      }
    }
  }
}
