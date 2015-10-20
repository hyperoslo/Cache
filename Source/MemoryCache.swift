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

  // MARK: - Initialization

  public required init(name: String) {
    cache.name = "\(prefix).\(name.capitalizedString)"
  }

  // MARK: - CacheAware

  public func add<T: Cachable>(key: String, object: T, start: Bool = true, completion: (() -> Void)? = nil) -> CacheTask? {
    let task = CacheTask { [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.cache.setObject(object, forKey: key)
    }

    return start ? task.start() : task
  }

  public func object<T: Cachable>(key: String, start: Bool = true, completion: (object: T?) -> Void) -> CacheTask? {
    let task = CacheTask { [weak self] in
      guard let weakSelf = self else { return }
      let cachedObject = weakSelf.cache.objectForKey(key) as? T
      completion(object: cachedObject)
    }

    return start ? task.start() : task
  }

  public func remove(key: String, start: Bool = true, completion: (() -> Void)? = nil) -> CacheTask? {
    let task = CacheTask { [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.cache.removeObjectForKey(key)
      completion?()
    }

    return start ? task.start() : task
  }

  public func clear(start: Bool = true, completion: (() -> Void)? = nil) -> CacheTask? {
    let task = CacheTask { [weak self] in
      guard let weakSelf = self else { return }
      weakSelf.cache.removeAllObjects()
      completion?()
    }

    return start ? task.start() : task
  }
}
