import Quick
import Nimble
@testable import Cache

class SyncHybridCacheSpec: QuickSpec {

  override func spec() {
    describe("SyncHybridCache") {
      let name = "WeirdoCache"
      let key = "alongweirdkey"
      let object = SpecHelper.user
      var cache: HybridCache!
      var syncer: SyncHybridCache!

      beforeEach {
        cache = HybridCache(name: name)
        syncer = SyncHybridCache(cache)
      }

      afterEach {
        cache.clear()
      }

      describe("#init") {
        it("sets a cache") {
          expect(syncer.cache).to(equal(cache))
        }
      }

      describe("#add") {
        it("saves an object to cache") {
          syncer.add(key, object: object)
          let receivedObject: User? = syncer.object(key)

          expect(receivedObject).toNot(beNil())
        }
      }

      describe("#object") {
        it("resolves cached object") {
          syncer.add(key, object: object)
          let receivedObject: User? = syncer.object(key)

          expect(receivedObject?.firstName).to(equal(object.firstName))
          expect(receivedObject?.lastName).to(equal(object.lastName))
        }
      }

      describe("#remove") {
        it("removes cached object from cache") {
          syncer.add(key, object: object)
          syncer.remove(key)
          let receivedObject: User? = syncer.object(key)

          expect(receivedObject).to(beNil())
        }
      }

      describe("#clear") {
        it("clears cache") {
          syncer.add(key, object: object)
          syncer.remove(key)
          let receivedObject: User? = syncer.object(key)

          expect(receivedObject).to(beNil())
        }
      }
    }
  }
}
