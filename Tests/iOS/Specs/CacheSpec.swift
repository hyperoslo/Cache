import Quick
import Nimble
@testable import Cache

class CacheSpec: QuickSpec {

  override func spec() {
    describe("Cache") {
      let name = "WeirdoCache"
      let key = "alongweirdkey"
      let object = SpecHelper.user
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
          expect(cache.config.backKind.name).to(equal(defaultConfig.backKind.name))
          expect(cache.config.expiry.date).to(equal(defaultConfig.expiry.date))
          expect(cache.config.maxSize).to(equal(defaultConfig.maxSize))
        }

        it("sets the front cache as a memory cache") {
          expect(cache.frontStorage.self is MemoryStorage).to(beTrue())
          expect(cache.backStorage.self is DiskStorage).to(beTrue())
        }
      }

      describe("#add") {
        it("saves an object to memory and disk") {
          let expectation1 = self.expectationWithDescription("Save Expectation")
          let expectation2 = self.expectationWithDescription("Save To Memory Expectation")
          let expectation3 = self.expectationWithDescription("Save To Disk Expectation")

          cache.add(key, object: object) {
            cache.object(key) { (receivedObject: User?) in
              expect(receivedObject).toNot(beNil())
              expectation1.fulfill()
            }

            cache.frontStorage.object(key) { (receivedObject: User?) in
              expect(receivedObject).toNot(beNil())
              expectation2.fulfill()
            }

            cache.backStorage.object(key) { (receivedObject: User?) in
              expect(receivedObject).toNot(beNil())
              expectation3.fulfill()
            }
          }

          self.waitForExpectationsWithTimeout(8.0, handler:nil)
        }
      }

      describe("#object") {
        it("resolves cached object") {
          let expectation = self.expectationWithDescription("Object Expectation")

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
        it("removes cached object from memory and disk") {
          let expectation1 = self.expectationWithDescription("Remove Expectation")
          let expectation2 = self.expectationWithDescription("Remove From Memory Expectation")
          let expectation3 = self.expectationWithDescription("Remove From Disk Expectation")

          cache.add(key, object: object)

          cache.remove(key) {
            cache.object(key) { (receivedObject: User?) in
              expect(receivedObject).to(beNil())
              expectation1.fulfill()
            }

            cache.frontStorage.object(key) { (receivedObject: User?) in
              expect(receivedObject).to(beNil())
              expectation2.fulfill()
            }

            cache.backStorage.object(key) { (receivedObject: User?) in
              expect(receivedObject).to(beNil())
              expectation3.fulfill()
            }
          }

          self.waitForExpectationsWithTimeout(8.0, handler:nil)
        }
      }

      describe("#clear") {
        it("clears memory and disk cache") {
          let expectation1 = self.expectationWithDescription("Clear Expectation")
          let expectation2 = self.expectationWithDescription("Clear Memory Expectation")
          let expectation3 = self.expectationWithDescription("Clear Disk Expectation")

          cache.add(key, object: object)

          cache.clear() {
            cache.object(key) { (receivedObject: User?) in
              expect(receivedObject).to(beNil())
              expectation1.fulfill()
            }

            cache.frontStorage.object(key) { (receivedObject: User?) in
              expect(receivedObject).to(beNil())
              expectation2.fulfill()
            }

            cache.backStorage.object(key) { (receivedObject: User?) in
              expect(receivedObject).to(beNil())
              expectation3.fulfill()
            }
          }

          self.waitForExpectationsWithTimeout(8.0, handler:nil)
        }
      }
    }
  }
}
