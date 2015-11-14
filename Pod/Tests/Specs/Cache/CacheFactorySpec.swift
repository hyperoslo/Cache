import Quick
import Nimble

class CacheFactorySpec: QuickSpec {

  override func spec() {
    describe("CacheFactory") {

      describe(".register") {
        it("adds an item to the list of registered caches") {
          CacheFactory.register(.Memory, cache: MemoryCache.self)
          let resolvedCache = CacheFactory.resolve("Test", kind: .Memory)

          expect(resolvedCache is MemoryCache).to(beTrue())
        }

        it("overrides an item in the list of registered caches") {
          CacheFactory.register(.Disk, cache: MemoryCache.self)
          let resolvedCache = CacheFactory.resolve("Test", kind: .Disk)

          expect(resolvedCache is MemoryCache).to(beTrue())
        }
      }

      describe(".resolve") {
        it("returns previously registerd cache") {
          let kind: CacheKind = .Custom("Cloud")
          CacheFactory.register(kind, cache: DiskCache.self)
          let resolvedCache = CacheFactory.resolve("Test", kind: kind)

          expect(resolvedCache is DiskCache).to(beTrue())
        }

        it("returns default registered caches") {
          CacheFactory.reset()
          let memoryCache = CacheFactory.resolve("Test", kind: .Memory)
          let diskCache = CacheFactory.resolve("Test", kind: .Disk, maxSize: 0)

          expect(memoryCache is MemoryCache).to(beTrue())
          expect(diskCache is DiskCache).to(beTrue())
        }

        it("returns memory cache for unresolved kind") {
          CacheFactory.reset()
          let resolvedCache = CacheFactory.resolve("Test", kind: .Custom("Weirdo"))

          expect(resolvedCache is MemoryCache).to(beTrue())
        }

        it("returns a cache with specified maxSize") {
          let resolvedCache = CacheFactory.resolve("Test", kind: .Memory, maxSize: 1000)
          expect(resolvedCache.maxSize).to(equal(1000))
        }
      }

      describe(".reset") {
        it("resets to defaults") {
          CacheFactory.register(.Disk, cache: MemoryCache.self)
          CacheFactory.reset()
          let resolvedCache = CacheFactory.resolve("Test", kind: .Disk)

          expect(resolvedCache is DiskCache).to(beTrue())
        }
      }
    }
  }
}
