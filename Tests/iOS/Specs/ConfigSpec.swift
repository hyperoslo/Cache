import Quick
import Nimble
@testable import Cache

class ConfigSpec: QuickSpec {

  override func spec() {
    describe("Config") {

      describe(".defaultConfig") {
        it("returns the correct default config") {
          let config = Config.defaultConfig

          expect(config.frontKind.name).to(equal(StorageKind.Memory.name))
          expect(config.backKind.name).to(equal(StorageKind.Disk.name))
          expect(config.expiry.date.timeIntervalSinceNow) ≈ Expiry.Never.date.timeIntervalSinceNow
          expect(config.maxSize).to(equal(0))
        }
      }
    }
  }
}
