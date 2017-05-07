import Quick
import Nimble
@testable import Cache

class ConfigSpec: QuickSpec {

  override func spec() {
    describe("Config") {

      describe(".defaultConfig") {
        it("returns the correct default config") {
          let config = Config.defaultConfig

          expect(config.frontKind.name).to(equal(StorageKind.memory.name))
          expect(config.backKind.name).to(equal(StorageKind.disk.name))
          expect(config.expiry.date).to(equal(Expiry.never.date))
          expect(config.maxSize).to(equal(0))
          expect(config.cacheDirectory).to(beNil())
        }
      }
    }
  }
}
