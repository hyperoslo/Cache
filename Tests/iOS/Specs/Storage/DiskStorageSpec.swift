import Quick
import Nimble
import SwiftHash
@testable import Cache

class DiskStorageSpec: QuickSpec {
  
  override func spec() {
    describe("DiskStorage") {
      let name = "Floppy"
      let key = "youknownothing"
      let object = SpecHelper.user
      let fileManager = FileManager()
      
      describe("Default") {
        var storage: DiskStorage!
        
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
            let paths = NSSearchPathForDirectoriesInDomains(
              .cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true
            )
            let path = "\(paths.first!)/\(name.capitalized)"
            expect(storage.path).to(equal(path))
          }
        }

        describe("#init") {
          it("creates cache directory") {
            let fileExist = fileManager.fileExists(atPath: storage.path)
            expect(fileExist).to(beTrue())
          }
        }

        describe("#maxSize") {
          it("returns the default maximum size of a cache") {
            expect(storage.maxSize).to(equal(0))
          }
        }

        describe("#setDirectoryAttributes") {
          it("sets attributes") {
            let storage = DiskStorage(name: name)
            try! storage.add(key, object: object)
            try! storage.setDirectoryAttributes([FileAttributeKey.immutable: true])
            var attributes = try! fileManager.attributesOfItem(atPath: storage.path)

            expect(attributes[FileAttributeKey.immutable] as? Bool).to(beTrue())
            try! storage.setDirectoryAttributes([FileAttributeKey.immutable: false])
          }
        }
        
        describe("#add") {
          it("creates cache directory") {
            try! storage.add(key, object: object)
            let fileExist = fileManager.fileExists(atPath: storage.path)
            expect(fileExist).to(beTrue())
          }
          
          it("saves an object") {
            try! storage.add(key, object: object)
            let fileExist = fileManager.fileExists(atPath: storage.makeFilePath(for: key))
            expect(fileExist).to(beTrue())
          }
        }
        
        describe("#cacheEntry") {
          it("returns nil if entry doesn't exist") {
            let storage = DiskStorage(name: name)
            var entry: CacheEntry<User>?
            do {
              entry = try storage.cacheEntry(key)
            } catch {}

            expect(entry).to(beNil())
          }
          
          it("returns entry if object exists") {
            let storage = DiskStorage(name: name)
            try! storage.add(key, object: object)
            let entry: CacheEntry<User>? = try! storage.cacheEntry(key)
            let attributes = try! fileManager.attributesOfItem(atPath: storage.makeFilePath(for: key))
            let expiry = Expiry.date(attributes[FileAttributeKey.modificationDate] as! Date)

            expect(entry?.object.firstName).to(equal(object.firstName))
            expect(entry?.object.lastName).to(equal(object.lastName))
            expect(entry?.expiry.date).to(equal(expiry.date))
          }
        }
        
        describe("#object") {
          it("resolves cached object") {
            try! storage.add(key, object: object)
            let receivedObject: User? = try! storage.object(key)
            expect(receivedObject?.firstName).to(equal(object.firstName))
            expect(receivedObject?.lastName).to(equal(object.lastName))
          }
        }
        
        describe("#remove") {
          it("removes cached object") {
            try! storage.add(key, object: object)
            try! storage.remove(key)
            let fileExist = fileManager.fileExists(atPath: storage.makeFilePath(for: key))
            expect(fileExist).to(beFalse())
          }
        }
        
        describe("removeIfExpired") {
          it("removes expired object") {
            let expiry: Expiry = .date(Date().addingTimeInterval(-100000))
            try! storage.add(key, object: object, expiry: expiry)
            try! storage.removeIfExpired(key)
            var receivedObject: User?
            do {
              receivedObject = try storage.object(key)
            } catch {}

            expect(receivedObject).to(beNil())
          }
          
          it("don't remove not expired object") {
            try! storage.add(key, object: object)
            try! storage.removeIfExpired(key)
            let receivedObject: User? = try! storage.object(key)
            expect(receivedObject).notTo(beNil())
          }
        }
        
        describe("#clear") {
          it("clears cache directory") {
            try! storage.add(key, object: object)
            try! storage.clear()
            let fileExist = fileManager.fileExists(atPath: storage.path)
            expect(fileExist).to(beFalse())
          }
        }
        
        describe("clearExpired") {
          it("removes expired objects") {
            let expiry1: Expiry = .date(Date().addingTimeInterval(-100000))
            let expiry2: Expiry = .date(Date().addingTimeInterval(100000))
            let key1 = "item1"
            let key2 = "item2"
            try! storage.add(key1, object: object, expiry: expiry1)
            try! storage.add(key2, object: object, expiry: expiry2)
            try! storage.clearExpired()
            var object1: User?
            let object2: User? = try! storage.object(key2)

            do {
              object1 = try storage.object(key1)
            } catch {}

            expect(object1).to(beNil())
            expect(object2).toNot(beNil())
          }
        }
        
        describe("#makeFileName") {
          it("returns a correct file name") {
            expect(storage.makeFileName(for: key)).to(equal(MD5(key)))
          }
        }
        
        describe("#makeFilePath") {
          it("returns a correct file path") {
            let filePath = "\(storage.path)/\(storage.makeFileName(for: key))"
            expect(storage.makeFilePath(for: key)).to(equal(filePath))
          }
        }
      }
      
      describe("CustomPath") {
        var path: String!
        var storage: DiskStorage!
        
        beforeEach {
          do {
            path = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).path
            storage = DiskStorage(name: name, cacheDirectory: path)
          } catch {}
        }
        
        afterEach {
          do {
            try fileManager.removeItem(atPath: storage.path)
          } catch {}
        }
        
        describe("#path") {
          it("returns the correct path") {
            do {
              let path = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).path
              
              expect(storage.path).to(equal(path))
            } catch {}
          }
        }
      }
    }
  }
}
