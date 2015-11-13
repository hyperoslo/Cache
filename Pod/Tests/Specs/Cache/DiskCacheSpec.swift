import Quick
import Nimble

class DiskCacheSpec: QuickSpec {

  override func spec() {
    describe("DiskCache") {
      let name = "DudeDiskCache"
      let key = "youknownothing"
      let object = User(firstName: "John", lastName: "Snow")
      var cache: DiskCache!
      let fileManager = NSFileManager()

      beforeEach {
        cache = DiskCache(name: name)
      }

      afterEach {
        do {
          try fileManager.removeItemAtPath(cache.path)
        } catch {}
      }

      describe("#path") {
        it("returns the correct path") {
          let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory,
            NSSearchPathDomainMask.UserDomainMask, true)
          let path = "\(paths.first!)/\(DiskCache.prefix).\(name.capitalizedString)"

          expect(cache.path).to(equal(path))
        }
      }

      describe("#maxSize") {
        it("returns the default maximum size of a cache") {
          expect(cache.maxSize).to(equal(0))
        }
      }

      describe("#add") {
        it("creates cache directory") {
          let expectation = self.expectationWithDescription(
            "Create Cache Directory Expectation")

          cache.add(key, object: object) {
            let fileExist = fileManager.fileExistsAtPath(cache.path)
            expect(fileExist).to(beTrue())
            expectation.fulfill()
          }

          self.waitForExpectationsWithTimeout(2.0, handler:nil)
        }

        it("saves an object") {
          let expectation = self.expectationWithDescription("Save Expectation")

          cache.add(key, object: object) {
            let fileExist = fileManager.fileExistsAtPath(cache.filePath(key))
            expect(fileExist).to(beTrue())
            expectation.fulfill()
          }

          self.waitForExpectationsWithTimeout(2.0, handler:nil)
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

          self.waitForExpectationsWithTimeout(2.0, handler:nil)
        }
      }

      describe("#remove") {
        it("removes cached object") {
          let expectation = self.expectationWithDescription("Remove Expectation")

          cache.add(key, object: object)
          cache.remove(key) {
            let fileExist = fileManager.fileExistsAtPath(cache.filePath(key))
            expect(fileExist).to(beFalse())
            expectation.fulfill()
          }

          self.waitForExpectationsWithTimeout(2.0, handler:nil)
        }
      }

      describe("removeIfExpired") {
        it("removes expired object") {
          let expectation = self.expectationWithDescription(
            "Remove If Expired Expectation")
          let expiry: Expiry = .Date(NSDate().dateByAddingTimeInterval(-100000))

          cache.add(key, object: object, expiry: expiry)
          cache.removeIfExpired(key) {
            cache.object(key) { (receivedObject: User?) in
              expect(receivedObject).to(beNil())
              expectation.fulfill()
            }
          }

          self.waitForExpectationsWithTimeout(2.0, handler:nil)
        }

        it("don't remove not expired object") {
          let expectation = self.expectationWithDescription(
            "Don't Remove If Not Expired Expectation")

          cache.add(key, object: object)
          cache.removeIfExpired(key) {
            cache.object(key) { (receivedObject: User?) in
              expect(receivedObject).notTo(beNil())
              expectation.fulfill()
            }
          }

          self.waitForExpectationsWithTimeout(2.0, handler:nil)
        }
      }

      describe("#clear") {
        it("clears cache directory") {
          let expectation = self.expectationWithDescription("Clear Expectation")

          cache.add(key, object: object)
          cache.clear() {
            let fileExist = fileManager.fileExistsAtPath(cache.path)
            expect(fileExist).to(beFalse())
            expectation.fulfill()
          }

          self.waitForExpectationsWithTimeout(2.0, handler:nil)
        }
      }

      describe("#fileName") {
        it("returns a correct file name") {
          expect(cache.fileName(key)).to(equal(key.base64()))
        }
      }

      describe("#filePath") {
        it("returns a correct file path") {
          let filePath = "\(cache.path)/\(cache.fileName(key))"
          expect(cache.filePath(key)).to(equal(filePath))
        }
      }
    }
  }
}
