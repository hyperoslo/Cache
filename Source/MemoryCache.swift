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
  public private(set) var writeQueue: dispatch_queue_t
  public private(set) var readQueue: dispatch_queue_t

  // MARK: - Initialization

  public required init(name: String) {
    cache.name = "\(MemoryCache.prefix).\(name.capitalizedString)"
    writeQueue = dispatch_queue_create("\(cache.name).WriteQueue", DISPATCH_QUEUE_SERIAL)
    readQueue = dispatch_queue_create("\(cache.name).ReadQueue", DISPATCH_QUEUE_SERIAL)
  }

  // MARK: - CacheAware

  public func add<T: Cachable>(key: String, object: T, expiry: Expiry = .Never, completion: (() -> Void)? = nil) {
    dispatch_async(writeQueue) { [weak self] in
      guard let weakSelf = self else { return }

      weakSelf.cache.setObject(object, forKey: key)
      completion?()
    }
  }

  public func object<T: Cachable>(key: String, completion: (object: T?) -> Void) {
    dispatch_async(readQueue) { [weak self] in
      guard let weakSelf = self else { return }

      let cachedObject = weakSelf.cache.objectForKey(key) as? T
      completion(object: cachedObject)
    }
  }

  public func remove(key: String, completion: (() -> Void)? = nil) {
    dispatch_async(writeQueue) { [weak self] in
      guard let weakSelf = self else { return }

      weakSelf.cache.removeObjectForKey(key)
      completion?()
    }
  }

  public func clear(completion: (() -> Void)? = nil) {
    dispatch_async(writeQueue) { [weak self] in
      guard let weakSelf = self else { return }

      weakSelf.cache.removeAllObjects()
      completion?()
    }
  }
}
