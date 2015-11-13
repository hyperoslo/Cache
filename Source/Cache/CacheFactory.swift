public class CacheFactory {

  private static var DefaultCache: CacheAware.Type = MemoryCache.self

  private static var defaultCaches: [String: CacheAware.Type] = [
    CacheKind.Memory.name : MemoryCache.self,
    CacheKind.Disk.name : DiskCache.self
  ]

  private static var caches = defaultCaches

  // MARK: - Factory

  static func register<T: CacheAware>(kind: CacheKind, cache: T.Type) {
    caches[kind.name] = cache
  }

  static func resolve(name: String, kind: CacheKind, maxSize: UInt = 0) -> CacheAware {
    let Cache: CacheAware.Type = caches[kind.name] ?? DefaultCache
    return Cache.init(name: name, maxSize: maxSize)
  }

  static func reset() {
    caches = defaultCaches
  }
}