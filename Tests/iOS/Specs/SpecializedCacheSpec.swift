import Quick
import Nimble
@testable import Cache

class SpecializedCacheSpec: QuickSpec {
  override func spec() {
    describe("Specialized") {
      let name = "WeirdoCache"
      let key = "alongweirdkey"
      let object = SpecHelper.user
      var cache: SpecializedCache<User>!

      beforeEach {
        cache = SpecializedCache<User>(name: name)
      }

      afterEach {
        cache.clear()
      }

      describe("#init") {
        it("sets a name") {
          expect(cache.name).to(equal(name))
        }

        it("sets a config") {
          let defaultConfig = Config()
          expect(cache.config.expiry.date).to(equal(defaultConfig.expiry.date))
          expect(cache.config.cacheDirectory).to(beNil())
          expect(cache.config.maxDiskSize).to(equal(defaultConfig.maxDiskSize))
          expect(cache.config.memoryCountLimit).to(equal(defaultConfig.memoryCountLimit))
          expect(cache.config.memoryTotalCostLimit).to(equal(defaultConfig.memoryTotalCostLimit))
          expect(cache.config.cacheDirectory == defaultConfig.cacheDirectory).to(beTrue())
        }
      }

      describe("#add") {
        it("saves an object to memory and disk") {
          let expectation1 = self.expectation(description: "Save Expectation")
          let expectation2 = self.expectation(description: "Save To Memory Expectation")
          let expectation3 = self.expectation(description: "Save To Disk Expectation")

          cache.add(key, object: object) { error in
            if let error = error {
              XCTFail("Failed with error: \(error)")
            }

            cache.object(key) { receivedObject in
              expect(receivedObject).toNot(beNil())
              expectation1.fulfill()
            }


            let memoryObject: User? = cache.frontStorage.object(key)
            expect(memoryObject).toNot(beNil())
            expectation2.fulfill()

            let diskObject: User? = try! cache.backStorage.object(key)
            expect(diskObject).toNot(beNil())
            expectation3.fulfill()
          }

          self.waitForExpectations(timeout: 1.0, handler:nil)
        }
      }
      
      describe("#cacheEntry") {
        it("resolves cache entry") {
          waitUntil(timeout: 1.0) { done in
            let expiryDate = Date()
            cache.add(key, object: object, expiry: .date(expiryDate)) { error in
              if let error = error {
                XCTFail("Failed with error: \(error)")
              }

              cache.cacheEntry(key) { entry in
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
          cache.add(key, object: object) { error in
            if let error = error {
              XCTFail("Failed with error: \(error)")
            }
            cache.object(key) { receivedObject in
              expect(receivedObject).toNot(beNil())
              expect(receivedObject?.firstName).to(equal(object.firstName))
              expect(receivedObject?.lastName).to(equal(object.lastName))
              expectation.fulfill()
            }
          }
          self.waitForExpectations(timeout: 1.0, handler:nil)
        }
        
        it("should resolve from disk and set in-memory cache if object not in-memory") {
          let frontStorage = MemoryStorage(name: "MemoryStorage")
          let backStorage = DiskStorage(name: "DiskStorage")
          let config = Config()
          let key = "myusernamedjohn"
          let object = SpecHelper.user
          
          let cache = SpecializedCache<User>(
            name: "MyCache",
            frontStorage: frontStorage,
            backStorage: backStorage,
            config: config
          )
          
          waitUntil(timeout: 1.0) { done in
            try! backStorage.add(key, object: object)
            cache.object(key) { receivedObject in
              expect(receivedObject).toNot(beNil())
              expect(receivedObject?.firstName).to(equal(object.firstName))
              expect(receivedObject?.lastName).to(equal(object.lastName))
                
              let inmemoryCachedUser: User? = frontStorage.object(key)
              expect(inmemoryCachedUser?.firstName).to(equal(object.firstName))
              expect(inmemoryCachedUser?.lastName).to(equal(object.lastName))
              done()
            }
          }
        }
      }

      describe("#remove") {
        it("removes cached object from memory and disk") {
          let expectation1 = self.expectation(description: "Remove Expectation")
          let expectation2 = self.expectation(description: "Remove From Memory Expectation")
          let expectation3 = self.expectation(description: "Remove From Disk Expectation")

          cache.add(key, object: object) { error in
            if let error = error {
              XCTFail("Failed with error: \(error)")
            }
            cache.remove(key) { error in
              if let error = error {
                XCTFail("Failed with error: \(error)")
              }

              cache.object(key) { object in
                expect(object).to(beNil())
                expectation1.fulfill()
              }

              let memoryObject: User? = cache.frontStorage.object(key)
              expect(memoryObject).to(beNil())
              expectation2.fulfill()

              var diskObject: User?
              do {
                diskObject = try cache.backStorage.object(key)
              } catch {}

              expect(diskObject).to(beNil())
              expectation3.fulfill()
            }
          }

          self.waitForExpectations(timeout: 1.0, handler:nil)
        }
      }

      describe("#clear") {
        it("clears memory and disk cache") {
          let expectation1 = self.expectation(description: "Clear Expectation")
          let expectation2 = self.expectation(description: "Clear Memory Expectation")
          let expectation3 = self.expectation(description: "Clear Disk Expectation")

          cache.add(key, object: object) { error in
            if let error = error {
              XCTFail("Failed with error: \(error)")
            }
            cache.clear() { error in
              if let error = error {
                XCTFail("Failed with error: \(error)")
              }

              cache.object(key) { object in
                expect(object).to(beNil())
                expectation1.fulfill()
              }

              let memoryObject: User? = cache.frontStorage.object(key)
              expect(memoryObject).to(beNil())
              expectation2.fulfill()

              var diskObject: User?
              do {
                diskObject = try cache.backStorage.object(key)
              } catch {}
              expect(diskObject).to(beNil())
              expectation3.fulfill()
            }
          }
          self.waitForExpectations(timeout: 1.0, handler:nil)
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
          
          cache.add(key1, object: object, expiry: expiry1) { error in
            if let error = error {
              XCTFail("Failed with error: \(error)")
            }
            cache.add(key2, object: object, expiry: expiry2) { error in
              if let error = error {
                XCTFail("Failed with error: \(error)")
              }
              cache.clearExpired() { error in
                if let error = error {
                  XCTFail("Failed with error: \(error)")
                }
                cache.object(key1) { object in
                  expect(object).to(beNil())
                  expectation1.fulfill()
                }
                cache.object(key2) { object in
                  expect(object).toNot(beNil())
                  expectation2.fulfill()
                }
              }
            }
          }
          
          self.waitForExpectations(timeout: 1.0, handler:nil)
        }
      }
    }
  }
}
