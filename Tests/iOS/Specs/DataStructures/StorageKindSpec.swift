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
            expect(StorageKind.permanentDisk.name).to(equal("PermanentDisk"))
        }

        it("returns the correct name for custom values") {
          expect(StorageKind.custom("Weirdo").name).to(equal("Weirdo"))
        }
      }
    }
  }
}
