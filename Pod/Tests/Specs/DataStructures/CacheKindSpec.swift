import Quick
import Nimble

class CacheKindSpec: QuickSpec {

  override func spec() {
    describe("CacheKind") {

      describe("#name") {
        it("returns the correct name for default values") {
          expect(CacheKind.Memory.name).to(equal("Memory"))
          expect(CacheKind.Disk.name).to(equal("Disk"))
        }

        it("returns the correct name for custom values") {
          expect(CacheKind.Custom("Weirdo").name).to(equal("Weirdo"))
        }
      }
    }
  }
}
