import Quick
import Nimble
@testable import Cache

class StorageKindSpec: QuickSpec {

  override func spec() {
    describe("StorageKind") {

      describe("#name") {
        it("returns the correct name for default values") {
          expect(StorageKind.memory.name).to(equal("Memory"))
          expect(StorageKind.disk.name).to(equal("Disk"))
        }

        it("returns the correct name for custom values") {
          expect(StorageKind.Custom("Weirdo").name).to(equal("Weirdo"))
        }
      }
    }
  }
}
