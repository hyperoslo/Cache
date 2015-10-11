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

  public let cache = NSCache()

  public required init(name: String) {
    cache.name = prefix + name
  }

  // MARK: - CacheAware

  public func add<T: Cachable>(key: String, object: T, completion: (() -> Void)? = nil) -> CacheTask? {
    return CacheTask { [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.cache.setObject(object, forKey: key)
    }
  }

  public func object<T: Cachable>(key: String, completion: (object: T?) -> Void) -> CacheTask? {
    return CacheTask { [weak self] in
      guard let weakSelf = self else { return }
      let cachedObject = weakSelf.cache.objectForKey(key) as? T
      completion(object: cachedObject)
    }
  }

  public func remove(key: String, completion: (() -> Void)? = nil) -> CacheTask? {
    return CacheTask { [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.cache.removeObjectForKey(key)
      completion?()
    }
  }

  public func clear(completion: (() -> Void)? = nil) -> CacheTask? {
    return CacheTask { [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.cache.removeAllObjects()
      completion?()
    }
  }
}
