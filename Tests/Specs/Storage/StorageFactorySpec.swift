import Quick
import Nimble
@testable import Cache

class StorageFactorySpec: QuickSpec {

  override func spec() {
    describe("StorageFactory") {

      describe(".register") {
        it("adds an item to the list of registered storages") {
          StorageFactory.register(.Memory, storage: MemoryStorage.self)
          let resolvedStorage = StorageFactory.resolve("Test", kind: .Memory)

          expect(resolvedStorage is MemoryStorage).to(beTrue())
        }

        it("overrides an item in the list of registered storages") {
          StorageFactory.register(.Disk, storage: MemoryStorage.self)
          let resolvedStorage = StorageFactory.resolve("Test", kind: .Disk)

          expect(resolvedStorage is MemoryStorage).to(beTrue())
        }
      }

      describe(".resolve") {
        it("returns previously registerd storage") {
          let kind: StorageKind = .Custom("Cloud")
          StorageFactory.register(kind, storage: DiskStorage.self)
          let resolvedStorage = StorageFactory.resolve("Test", kind: kind)

          expect(resolvedStorage is DiskStorage).to(beTrue())
        }

        it("returns default registered storages") {
          StorageFactory.reset()
          let memoryStorage = StorageFactory.resolve("Test", kind: .Memory)
          let diskStorage = StorageFactory.resolve("Test", kind: .Disk, maxSize: 0)

          expect(memoryStorage is MemoryStorage).to(beTrue())
          expect(diskStorage is DiskStorage).to(beTrue())
        }

        it("returns memory storage for unresolved kind") {
          StorageFactory.reset()
          let resolvedStorage = StorageFactory.resolve("Test", kind: .Custom("Weirdo"))

          expect(resolvedStorage is MemoryStorage).to(beTrue())
        }

        it("returns a storage with specified maxSize") {
          let resolvedStorage = StorageFactory.resolve("Test", kind: .Memory, maxSize: 1000)
          expect(resolvedStorage.maxSize).to(equal(1000))
        }
      }

      describe(".reset") {
        it("resets to defaults") {
          StorageFactory.register(.Disk, storage: MemoryStorage.self)
          StorageFactory.reset()
          let resolvedStorage = StorageFactory.resolve("Test", kind: .Disk)

          expect(resolvedStorage is DiskStorage).to(beTrue())
        }
      }
    }
  }
}
