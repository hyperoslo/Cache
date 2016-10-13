import Quick
import Nimble
import CryptoSwift
@testable import Cache

class DiskStorageSpec: QuickSpec {

  override func spec() {
    describe("DiskStorage") {
      let name = "Floppy"
      let key = "youknownothing"
      let object = SpecHelper.user
      var storage: DiskStorage!
      let fileManager = FileManager()

      beforeEach {
        storage = DiskStorage(name: name)
      }

      afterEach {
        do {
          try fileManager.removeItem(atPath: storage.path)
        } catch {}
      }

      describe("#path") {
        it("returns the correct path") {
          let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory,
            FileManager.SearchPathDomainMask.userDomainMask, true)
          let path = "\(paths.first!)/\(DiskStorage.prefix).\(name.capitalized)"

          expect(storage.path).to(equal(path))
        }
      }

      describe("#maxSize") {
        it("returns the default maximum size of a cache") {
          expect(storage.maxSize).to(equal(0))
        }
      }

      describe("#add") {
        it("creates cache directory") {
          let expectation = self.expectation(description: "Create Cache Directory Expectation")

          storage.add(key, object: object) {
            let fileExist = fileManager.fileExists(atPath: storage.path)
            expect(fileExist).to(beTrue())
            expectation.fulfill()
          }

          self.waitForExpectations(timeout: 2.0, handler:nil)
        }

        it("saves an object") {
          let expectation = self.expectation(description: "Save Expectation")

          storage.add(key, object: object) {
            let fileExist = fileManager.fileExists(atPath: storage.filePath(key))
            expect(fileExist).to(beTrue())
            expectation.fulfill()
          }

          self.waitForExpectations(timeout: 2.0, handler:nil)
        }
      }

      describe("#object") {
        it("resolves cached object") {
          let expectation = self.expectation(description: "Object Expectation")

          storage.add(key, object: object) {
            storage.object(key) { (receivedObject: User?) in
              expect(receivedObject?.firstName).to(equal(object.firstName))
              expect(receivedObject?.lastName).to(equal(object.lastName))
              expectation.fulfill()
            }
          }

          self.waitForExpectations(timeout: 2.0, handler:nil)
        }
      }

      describe("#remove") {
        it("removes cached object") {
          let expectation = self.expectation(description: "Remove Expectation")

          storage.add(key, object: object)
          storage.remove(key) {
            let fileExist = fileManager.fileExists(atPath: storage.filePath(key))
            expect(fileExist).to(beFalse())
            expectation.fulfill()
          }

          self.waitForExpectations(timeout: 2.0, handler:nil)
        }
      }

      describe("removeIfExpired") {
        it("removes expired object") {
          let expectation = self.expectation(description: "Remove If Expired Expectation")
          let expiry: Expiry = .date(Date().addingTimeInterval(-100000))

          storage.add(key, object: object, expiry: expiry)
          storage.removeIfExpired(key) {
            storage.object(key) { (receivedObject: User?) in
              expect(receivedObject).to(beNil())
              expectation.fulfill()
            }
          }

          self.waitForExpectations(timeout: 2.0, handler:nil)
        }

        it("don't remove not expired object") {
          let expectation = self.expectation(description: "Don't Remove If Not Expired Expectation")

          storage.add(key, object: object)
          storage.removeIfExpired(key) {
            storage.object(key) { (receivedObject: User?) in
              expect(receivedObject).notTo(beNil())
              expectation.fulfill()
            }
          }

          self.waitForExpectations(timeout: 2.0, handler:nil)
        }
      }

      describe("#clear") {
        it("clears cache directory") {
          let expectation = self.expectation(description: "Clear Expectation")

          storage.add(key, object: object)
          storage.clear() {
            let fileExist = fileManager.fileExists(atPath: storage.path)
            expect(fileExist).to(beFalse())
            expectation.fulfill()
          }

          self.waitForExpectations(timeout: 2.0, handler:nil)
        }
      }

      describe("clearExpired") {
        it("removes expired objects") {
          let expectation1 = self.expectation(description: "Clear If Expired Expectation")
          let expectation2 = self.expectation(description: "Don't Clear If Not Expired Expectation")

          let expiry1: Expiry = .date(Date().addingTimeInterval(-100000))
          let expiry2: Expiry = .date(Date().addingTimeInterval(100000))

          let key1 = "item1"
          let key2 = "item2"

          storage.add(key1, object: object, expiry: expiry1)
          storage.add(key2, object: object, expiry: expiry2)

          storage.clearExpired {
            storage.object(key1) { (receivedObject: User?) in
              expect(receivedObject).to(beNil())
              expectation1.fulfill()
            }

            storage.object(key2) { (receivedObject: User?) in
              expect(receivedObject).toNot(beNil())
              expectation2.fulfill()
            }
          }

          self.waitForExpectations(timeout: 5.0, handler:nil)
        }
      }

      describe("#fileName") {
        it("returns a correct file name") {
          if let digest = key.data(using: String.Encoding.utf8)?.md5() {
            var string = ""

            for byte in digest {
              string += String(format:"%02x", byte)
            }
                
            expect(storage.fileName(key)).to(equal(string))
          } else {
            expect(storage.fileName(key)).to(equal(key.base64()))
          }
        }
      }

      describe("#filePath") {
        it("returns a correct file path") {
          let filePath = "\(storage.path)/\(storage.fileName(key))"
          expect(storage.filePath(key)).to(equal(filePath))
        }
      }
    }
  }
}
