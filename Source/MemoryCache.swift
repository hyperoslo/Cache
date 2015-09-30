import Foundation

public class MemoryCache {
  public let prefix = "no.hyper.Cache.Memory"

  private let cache = NSCache()

  public var maxSize: UInt = 0 {
    didSet(value) {
      self.cache.totalCostLimit = Int(maxSize)
    }
  }

  public init(name: String) {
    cache.name = prefix + name
  }

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
