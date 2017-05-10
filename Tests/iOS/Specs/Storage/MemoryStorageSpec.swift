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
        storage = MemoryStorage(name: name)
      }

      afterEach {
        storage.clear()
      }

      describe("#path") {
        it("returns the correct path") {
          let path = "\(MemoryStorage.prefix).\(name.capitalized)"
          
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
          let expectation = self.expectation(description: "Save Object Expectation")

          storage.add(key, object: object) {
            storage.object(key) { (receivedObject: User?) in
              expect(receivedObject).toNot(beNil())
              expectation.fulfill()
            }
          }

          self.waitForExpectations(timeout: 2.0, handler:nil)
        }
      }
      
      describe("#objectMetadata") {
        it("returns nil if object doesn't exist") {
          let storage = MemoryStorage(name: name)
          
          waitUntil(timeout: 2.0) { done in
            
            storage.objectMetadata(key) { metadata in
              expect(metadata).to(beNil())
              done()
            }
          }
        }
        
        it("returns object metadata if object exists") {
          let storage = MemoryStorage(name: name)
          let expiry = Expiry.date(Date())
          
          waitUntil(timeout: 2.0) { done in
            
            storage.add(key, object: object, expiry: expiry) {
              storage.objectMetadata(key) { metadata in
                
                let expectedMetadata = ObjectMetadata(expiry: expiry)
                expect(metadata).to(equal(expectedMetadata))
                done()
              }
            }
          }
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
            storage.object(key) { (receivedObject: User?) in
              expect(receivedObject).to(beNil())
              expectation.fulfill()
            }
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

          self.waitForExpectations(timeout: 4.0, handler:nil)
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

          self.waitForExpectations(timeout: 4.0, handler:nil)
        }
      }

      describe("#clear") {
        it("clears cache directory") {
          let expectation = self.expectation(description: "Clear Expectation")

          storage.add(key, object: object)
          storage.clear() {
            storage.object(key) { (receivedObject: User?) in
              expect(receivedObject).to(beNil())
              expectation.fulfill()
            }
          }

          self.waitForExpectations(timeout: 2.0, handler:nil)
        }
      }

      describe("clearExpired") {
        it("removes expired objects") {
          let expectation1 = self.expectation(description: "Clear Expired Expectation 1")
          let expectation2 = self.expectation(description: "Clear Expired Expectation 2")

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
              expect(receivedObject).to(beNil())
              expectation2.fulfill()
            }
          }

          self.waitForExpectations(timeout: 5.0, handler:nil)
        }
      }
    }
  }
}
