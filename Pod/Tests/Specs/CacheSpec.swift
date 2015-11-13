import Quick
import Nimble

class CacheSpec: QuickSpec {

  override func spec() {
    describe("Cache") {
      let name = "WeirdoCache"
      let key = "alongweirdkey"
      let object = User(firstName: "John", lastName: "Snow")
      var cache: Cache<User>!

      beforeEach {
        cache = Cache<User>(name: name)
      }

      afterEach {
        cache.clear()
      }

      describe("#init") {

        it("sets a name") {
          expect(cache.name).to(equal(name))
        }

        it("sets a config") {
          let defaultConfig = Config.defaultConfig

          expect(cache.config.frontKind.name).to(equal(defaultConfig.frontKind.name))
          expect(cache.config.backKind!.name).to(equal(defaultConfig.backKind!.name))
          expect(cache.config.expiry.date).to(equal(defaultConfig.expiry.date))
          expect(cache.config.maxSize).to(equal(defaultConfig.maxSize))
        }

        it("sets the front cache as a memory cache") {
          expect(cache.frontCache.self is MemoryCache).to(beTrue())
          expect(cache.backCache).toNot(beNil())
          expect(cache.backCache!.self is DiskCache).to(beTrue())
        }
      }

      describe("#add") {
        it("saves an object") {
          let expectation = self.expectationWithDescription(
            "Save Object Expectation")

          cache.add(key, object: object) {
            cache.object(key) { (receivedObject: User?) in
              expect(receivedObject).toNot(beNil())
              expectation.fulfill()
            }
          }

          self.waitForExpectationsWithTimeout(4.0, handler:nil)
        }
      }

      describe("#object") {
        it("resolves cached object") {
          let expectation = self.expectationWithDescription(
            "Object Expectation")

          cache.add(key, object: object) {
            cache.object(key) { (receivedObject: User?) in
              expect(receivedObject?.firstName).to(equal(object.firstName))
              expect(receivedObject?.lastName).to(equal(object.lastName))
              expectation.fulfill()
            }
          }

          self.waitForExpectationsWithTimeout(4.0, handler:nil)
        }
      }

      describe("#remove") {
        it("removes cached object") {
          let expectation = self.expectationWithDescription(
            "Remove Expectation")

          cache.add(key, object: object)
          cache.remove(key) {
            cache.object(key) { (receivedObject: User?) in
              expect(receivedObject).to(beNil())
              expectation.fulfill()
            }
          }

          self.waitForExpectationsWithTimeout(4.0, handler:nil)
        }
      }

      describe("#clear") {
        it("clears cache directory") {
          let expectation = self.expectationWithDescription(
            "Clear Expectation")

          cache.add(key, object: object)
          cache.clear() {
            cache.object(key) { (receivedObject: User?) in
              expect(receivedObject).to(beNil())
              expectation.fulfill()
            }
          }
          
          self.waitForExpectationsWithTimeout(4.0, handler:nil)
        }
      }
    }
  }
}
