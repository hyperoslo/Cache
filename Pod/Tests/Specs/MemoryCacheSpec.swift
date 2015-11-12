import Quick
import Nimble

class MemoryCacheSpec: QuickSpec {

  override func spec() {
    describe("MemoryCache") {
      let name = "DudeMemoryCache"
      let key = "youknownothing"
      let object = User(firstName: "John", lastName: "Snow")
      var cache: MemoryCache!

      beforeEach {
        cache = MemoryCache(name: name)
      }

      afterEach {
        cache.clear()
      }

      describe("#path") {
        it("returns the correct path") {
          let path = "\(MemoryCache.prefix).\(name.capitalizedString)"
          
          expect(cache.path).to(equal(path))
        }
      }

      describe("#maxSize") {
        it("returns the default maximum size of a cache") {
          expect(cache.maxSize).to(equal(0))
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

          self.waitForExpectationsWithTimeout(2.0, handler:nil)
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

          self.waitForExpectationsWithTimeout(2.0, handler:nil)
        }
      }

      describe("#remove") {
        it("removes cached object") {
          let expectation = self.expectationWithDescription(
            "Remove Expectation")

          cache.add(key, object: object)
          cache.remove(key)
          cache.object(key) { (receivedObject: User?) in
            expect(receivedObject).to(beNil())
            expectation.fulfill()
          }

          self.waitForExpectationsWithTimeout(2.0, handler:nil)
        }
      }

      describe("#clear") {
        it("clears cache directory") {
          let expectation = self.expectationWithDescription(
            "Clear Expectation")

          cache.add(key, object: object)
          cache.clear()

          cache.object(key) { (receivedObject: User?) in
            expect(receivedObject).to(beNil())
            expectation.fulfill()
          }

          self.waitForExpectationsWithTimeout(2.0, handler:nil)
        }
      }
    }
  }
}
