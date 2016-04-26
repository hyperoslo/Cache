import Quick
import Nimble
@testable import Cache

class SyncerSpec: QuickSpec {

  override func spec() {
    describe("Syncer") {
      let name = "WeirdoCache"
      let key = "alongweirdkey"
      let object = SpecHelper.user
      var cache: Cache<User>!
      var syncer: Syncer<User>!

      beforeEach {
        cache = Cache<User>(name: name)
        syncer = Syncer(cache)
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
          expect(syncer.object(key)).toNot(beNil())
        }
      }

      describe("#object") {
        it("resolves cached object") {
          syncer.add(key, object: object)
          let receivedObject = syncer.object(key)

          expect(receivedObject?.firstName).to(equal(object.firstName))
          expect(receivedObject?.lastName).to(equal(object.lastName))
        }
      }

      describe("#remove") {
        it("removes cached object from cache") {
          syncer.add(key, object: object)
          syncer.remove(key)

          expect(syncer.object(key)).to(beNil())
        }
      }

      describe("#clear") {
        it("clears cache") {
          syncer.add(key, object: object)
          syncer.remove(key)

          expect(syncer.object(key)).to(beNil())
        }
      }
    }
  }
}
