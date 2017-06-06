import Quick
import Nimble
@testable import Cache

class MemoryStorageSpec: QuickSpec {

  override func spec() {
    describe("MemoryStorage") {
      let name = "Brain"
      let key = "youknownothing"
      let object = SpecHelper.user
      var storage: MemoryStorage!

      beforeEach {
        storage = MemoryStorage.init(name: name)
      }

      afterEach {
        storage.clear()
      }

      describe("#add") {
        it("saves an object") {
          storage.add(key, object: object)
          let receivedObject: User? = storage.object(key)
          expect(receivedObject).toNot(beNil())
        }
      }
      
      describe("#cacheEntry") {
        it("returns nil if entry doesn't exist") {
          let entry: CacheEntry<User>? = storage.cacheEntry(key)
          expect(entry).to(beNil())
        }
        
        it("returns entry if object exists") {
          let expiry = Expiry.date(Date())
          storage.add(key, object: object, expiry: expiry)
          let entry: CacheEntry<User>? = storage.cacheEntry(key)
          expect(entry?.object.firstName).to(equal(object.firstName))
          expect(entry?.object.lastName).to(equal(object.lastName))
          expect(entry?.expiry.date).to(equal(expiry.date))
        }
      }
      
      describe("#object") {
        it("resolves cached object") {
          storage.add(key, object: object)
          let receivedObject: User? = storage.object(key)
          expect(receivedObject?.firstName).to(equal(object.firstName))
          expect(receivedObject?.lastName).to(equal(object.lastName))
        }
      }

      describe("#remove") {
        it("removes cached object") {
          storage.add(key, object: object)
          storage.remove(key)
          let receivedObject: User? = storage.object(key)
          expect(receivedObject).to(beNil())
        }
      }

      describe("removeIfExpired") {
        it("removes expired object") {
          let expiry: Expiry = .date(Date().addingTimeInterval(-100000))
          storage.add(key, object: object, expiry: expiry)
          storage.removeIfExpired(key)
          let receivedObject: User? = storage.object(key)
          expect(receivedObject).to(beNil())
        }

        it("don't remove not expired object") {
          storage.add(key, object: object)
          storage.removeIfExpired(key)
          let receivedObject: User? = storage.object(key)
          expect(receivedObject).notTo(beNil())
        }
      }

      describe("#clear") {
        it("clears cache directory") {
          storage.add(key, object: object)
          storage.clear()
          let receivedObject: User? = storage.object(key)
          expect(receivedObject).to(beNil())
        }
      }

      describe("clearExpired") {
        it("removes expired objects") {
          let expiry1: Expiry = .date(Date().addingTimeInterval(-100000))
          let expiry2: Expiry = .date(Date().addingTimeInterval(100000))
          let key1 = "item1"
          let key2 = "item2"
          storage.add(key1, object: object, expiry: expiry1)
          storage.add(key2, object: object, expiry: expiry2)
          storage.clearExpired()
          let object1: User? = storage.object(key1)
          let object2: User? = storage.object(key2)

          expect(object1).to(beNil())
          expect(object2).to(beNil())
        }
      }
    }
  }
}
