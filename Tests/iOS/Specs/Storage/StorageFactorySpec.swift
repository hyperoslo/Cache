import Quick
import Nimble
@testable import Cache

class StorageFactorySpec: QuickSpec {

  override func spec() {
    describe("StorageFactory") {

      describe(".register") {
        it("adds an item to the list of registered storages") {
          StorageFactory.register(.memory, storage: MemoryStorage.self)
          let resolvedStorage = StorageFactory.resolve("Test", kind: .memory)

          expect(resolvedStorage is MemoryStorage).to(beTrue())
        }

        it("overrides an item in the list of registered storages") {
          StorageFactory.register(.disk, storage: MemoryStorage.self)
          let resolvedStorage = StorageFactory.resolve("Test", kind: .disk)

          expect(resolvedStorage is MemoryStorage).to(beTrue())
        }
      }

      describe(".resolve") {
        it("returns previously registerd storage") {
          let kind: StorageKind = .custom("Cloud")
          StorageFactory.register(kind, storage: DiskStorage.self)
          let resolvedStorage = StorageFactory.resolve("Test", kind: kind)

          expect(resolvedStorage is DiskStorage).to(beTrue())
        }

        it("returns default registered storages") {
          StorageFactory.reset()
          let memoryStorage = StorageFactory.resolve("Test", kind: .memory)
          let diskStorage = StorageFactory.resolve("Test", kind: .disk, maxSize: 0)

          expect(memoryStorage is MemoryStorage).to(beTrue())
          expect(diskStorage is DiskStorage).to(beTrue())
        }

        it("returns memory storage for unresolved kind") {
          StorageFactory.reset()
          let resolvedStorage = StorageFactory.resolve("Test", kind: .custom("Weirdo"))

          expect(resolvedStorage is MemoryStorage).to(beTrue())
        }

        it("returns a storage with specified maxSize") {
          let resolvedStorage = StorageFactory.resolve("Test", kind: .memory, maxSize: 1000)
          expect(resolvedStorage.maxSize).to(equal(1000))
        }
      }

      describe(".reset") {
        it("resets to defaults") {
          StorageFactory.register(.disk, storage: MemoryStorage.self)
          StorageFactory.reset()
          let resolvedStorage = StorageFactory.resolve("Test", kind: .disk)

          expect(resolvedStorage is DiskStorage).to(beTrue())
        }
      }
    }
  }
}
