import Quick
import Nimble

class MemoryStorageSpec: QuickSpec {

  override func spec() {
    describe("MemoryStorage") {
      let name = "Brain"
      let key = "youknownothing"
      let object = SpecHelper.user
      var storage: MemoryStorage!

      beforeEach {
        storage = MemoryStorage(name: name)
      }

      afterEach {
        storage.clear()
      }

      describe("#path") {
        it("returns the correct path") {
          let path = "\(MemoryStorage.prefix).\(name.capitalizedString)"
          
          expect(storage.path).to(equal(path))
        }
      }

      describe("#maxSize") {
        it("returns the default maximum size of a cache") {
          expect(storage.maxSize).to(equal(0))
        }
      }

      describe("#add") {
        it("saves an object") {
          let expectation = self.expectationWithDescription(
            "Save Object Expectation")

          storage.add(key, object: object) {
            storage.object(key) { (receivedObject: User?) in
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

          storage.add(key, object: object) {
            storage.object(key) { (receivedObject: User?) in
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

          storage.add(key, object: object)
          storage.remove(key) {
            storage.object(key) { (receivedObject: User?) in
              expect(receivedObject).to(beNil())
              expectation.fulfill()
            }
          }

          self.waitForExpectationsWithTimeout(2.0, handler:nil)
        }
      }

      describe("removeIfExpired") {
        it("removes expired object") {
          let expectation = self.expectationWithDescription(
            "Remove If Expired Expectation")
          let expiry: Expiry = .Date(NSDate().dateByAddingTimeInterval(-100000))

          storage.add(key, object: object, expiry: expiry)
          storage.removeIfExpired(key) {
            storage.object(key) { (receivedObject: User?) in
              expect(receivedObject).to(beNil())
              expectation.fulfill()
            }
          }

          self.waitForExpectationsWithTimeout(4.0, handler:nil)
        }

        it("don't remove not expired object") {
          let expectation = self.expectationWithDescription(
            "Don't Remove If Not Expired Expectation")

          storage.add(key, object: object)
          storage.removeIfExpired(key) {
            storage.object(key) { (receivedObject: User?) in
              expect(receivedObject).notTo(beNil())
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

          storage.add(key, object: object)
          storage.clear() {
            storage.object(key) { (receivedObject: User?) in
              expect(receivedObject).to(beNil())
              expectation.fulfill()
            }
          }

          self.waitForExpectationsWithTimeout(2.0, handler:nil)
        }
      }
    }
  }
}
