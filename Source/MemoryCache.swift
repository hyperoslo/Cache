import Foundation

public class MemoryCache: CacheAware {
  public let prefix = "no.hyper.Cache.Memory"

  public var path: String {
    return cache.name
  }

  public var maxSize: UInt = 0 {
    didSet(value) {
      self.cache.totalCostLimit = Int(maxSize)
    }
  }

  private let cache = NSCache()

  public required init(name: String) {
    cache.name = prefix + name
  }

  // MARK: - CacheAware

  public func add<T: AnyObject>(key: String, object: T) {
    cache.setObject(object, forKey: key)
  }

  public func object<T: AnyObject>(key: String) -> T? {
    return cache.objectForKey(key) as? T
  }

  public func remove(key: String) {
    cache.removeObjectForKey(key)
  }

  public func clear() {
    cache.removeAllObjects()
  }
}
