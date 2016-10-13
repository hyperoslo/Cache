import Quick
import Nimble
@testable import Cache

class NSImageCacheSpec: QuickSpec {

  override func spec() {
    describe("NSImage+Cache") {

      describe("Cachable") {
        describe(".decode") {
          it("decodes from NSData") {
            let image = SpecHelper.image()
            let data = image.encode()!
            let result = NSImage.decode(data)!

            expect(result.isEqualToImage(image: image)).to(beTrue())
          }
        }

        describe("#encode") {
          it("encodes to NSData") {
            let image = SpecHelper.image()
            let representation = image.tiffRepresentation!

            let imageFileType: NSBitmapImageFileType = image.hasAlpha ? .PNG : .JPEG
            let data = NSBitmapImageRep(data: representation)!.representation(
              using: imageFileType, properties: [:])

            let result = image.encode()!

            expect(result).to(equal(data))
          }
        }
      }
    }
  }
}
