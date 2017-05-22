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
          
          /**
            I don't see a clear way to compare optional values via `Nimble` predicates,
            so do it directly
           */
          expect(cache.config.cacheDirectory == defaultConfig.cacheDirectory).to(beTrue())
        }

        it("sets the front cache as a memory cache") {
          expect(cache.frontStorage.self is MemoryStorage).to(beTrue())
          expect(cache.backStorage.self is DiskStorage).to(beTrue())
        }
      }

      describe("#add") {
        it("saves an object to memory and disk") {
          let expectation1 = self.expectation(description: "Save Expectation")
          let expectation2 = self.expectation(description: "Save To Memory Expectation")
          let expectation3 = self.expectation(description: "Save To Disk Expectation")

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

          self.waitForExpectations(timeout: 8.0, handler:nil)
        }
      }
      
      describe("#cacheEntry") {
        it("resolves cache entry") {
          waitUntil(timeout: 4.0) { done in
            let expiryDate = Date()
            
            cache.add(key, object: object, expiry: .date(expiryDate)) {
              cache.cacheEntry(key) { (entry: CacheEntry<User>?) in
                expect(entry?.object.firstName).to(equal(object.firstName))
                expect(entry?.object.lastName).to(equal(object.lastName))
                expect(entry?.expiry.date).to(equal(expiryDate))
                
                done()
              }
            }
          }
        }
      }
      
      describe("#object") {
        it("resolves cached object") {
          let expectation = self.expectation(description: "Object Expectation")
          
          cache.add(key, object: object) {
            cache.object(key) { (receivedObject: User?) in
              expect(receivedObject?.firstName).to(equal(object.firstName))
              expect(receivedObject?.lastName).to(equal(object.lastName))
              expectation.fulfill()
            }
          }
          
          self.waitForExpectations(timeout: 4.0, handler:nil)
        }
        
        it("should resolve from disk and set in-memory cache if object not in-memory") {
          let frontStorage = MemoryStorage(name: "MemoryStorage")
          let backStorage = DiskStorage(name: "DiskStorage")
          let config = Config.defaultConfig
          let key = "myusernamedjohn"
          let object = SpecHelper.user
          
          let cache = Cache<User>(name: "MyCache", frontStorage: frontStorage, backStorage: backStorage, config: config)
          
          waitUntil(timeout: 4.0) { done in
            
            backStorage.add(key, object: object) {
              
              cache.object(key) { (receivedObject: User?) in
                
                expect(receivedObject?.firstName).to(equal(object.firstName))
                expect(receivedObject?.lastName).to(equal(object.lastName))
                
                frontStorage.object(key) { (inmemoryCachedUser: User?) in
                  expect(inmemoryCachedUser?.firstName).to(equal(object.firstName))
                  expect(inmemoryCachedUser?.lastName).to(equal(object.lastName))
                  done()
                }
              }
            }
          }
        }
      }

      describe("#remove") {
        it("removes cached object from memory and disk") {
          let expectation1 = self.expectation(description: "Remove Expectation")
          let expectation2 = self.expectation(description: "Remove From Memory Expectation")
          let expectation3 = self.expectation(description: "Remove From Disk Expectation")

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

          self.waitForExpectations(timeout: 8.0, handler:nil)
        }
      }

      describe("#clear") {
        it("clears memory and disk cache") {
          let expectation1 = self.expectation(description: "Clear Expectation")
          let expectation2 = self.expectation(description: "Clear Memory Expectation")
          let expectation3 = self.expectation(description: "Clear Disk Expectation")

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

          self.waitForExpectations(timeout: 8.0, handler:nil)
        }
      }
      
      describe("#clearExpired") {
        it("clears expired objects from memory and disk cache") {
          let expectation1 = self.expectation(description: "Clear If Expired Expectation")
          let expectation2 = self.expectation(description: "Don't Clear If Not Expired Expectation")
          
          let expiry1: Expiry = .date(Date().addingTimeInterval(-100000))
          let expiry2: Expiry = .date(Date().addingTimeInterval(100000))
          
          let key1 = "key1"
          let key2 = "key2"
          
          cache.add(key1, object: object, expiry: expiry1) {
            cache.add(key2, object: object, expiry: expiry2) {
              cache.clearExpired() {
                cache.object(key1) { (receivedObject: User?) in
                  expect(receivedObject).to(beNil())
                  expectation1.fulfill()
                }
                
                cache.object(key2) { (receivedObject: User?) in
                  expect(receivedObject).toNot(beNil())
                  expectation2.fulfill()
                }
              }
            }
          }
          
          self.waitForExpectations(timeout: 5.0, handler:nil)
        }
      }
    }
  }
}
