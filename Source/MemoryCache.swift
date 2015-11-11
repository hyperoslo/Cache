import Foundation

public class MemoryCache: CacheAware {

  public static let prefix = "no.hyper.Cache.Memory"


  public var path: String {
    return cache.name
  }

  public var maxSize: UInt = 0 {
    didSet(value) {
      self.cache.totalCostLimit = Int(maxSize)
    }
  }

  public let cache = NSCache()
  

  // MARK: - Initialization

  public required init(name: String) {
    cache.name = "\(MemoryCache.prefix).\(name.capitalizedString)"
  }

  // MARK: - CacheAware

  public func add<T: Cachable>(key: String, object: T, completion: (() -> Void)? = nil) {
    cache.setObject(object, forKey: key)
  }

  public func object<T: Cachable>(key: String, completion: (object: T?) -> Void) {
    let cachedObject = cache.objectForKey(key) as? T
    completion(object: cachedObject)
  }

  public func remove(key: String, completion: (() -> Void)? = nil) {
    cache.removeObjectForKey(key)
    completion?()
  }

  public func clear(completion: (() -> Void)? = nil) {
    cache.removeAllObjects()
    completion?()
  }
}
