public enum CacheKind {
  case Memory
  case Disk
  case Custom(String)

  public var name: String {
    let result: String

    switch self {
    case .Memory:
      result = "memory"
    case .Disk:
      result = "seconds"
    case .Custom(let name):
      result = name
    }

    return result
  }
}

public class CacheFactory {

  private static var DefaultCache: CacheAware.Type = MemoryCache.self

  private static var caches: [String: CacheAware.Type] = [
    CacheKind.Memory.name : MemoryCache.self,
    CacheKind.Disk.name : DiskCache.self
  ]

  static func register<T: CacheAware>(kind: String, cache: T.Type) {
    caches[kind] = cache
  }

  static func resolve(name: String, kind: CacheKind, maxSize: UInt) -> CacheAware {
    let Cache: CacheAware.Type = caches[name] ?? DefaultCache
    return Cache.init(name: name, maxSize: maxSize)
  }
}