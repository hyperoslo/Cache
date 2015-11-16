import Foundation

public class Cache<T: Cachable> {

  public let name: String

  let config: Config
  let frontCache: StorageAware
  var backCache: StorageAware?

  // MARK: - Inititalization

  public init(name: String, config: Config = Config.defaultConfig) {
    self.name = name
    self.config = config

    frontCache = CacheFactory.resolve(name, kind: config.frontKind, maxSize: config.maxSize)
    if let backKind = config.backKind {
      backCache = CacheFactory.resolve(name, kind: backKind, maxSize: config.maxSize)
    }
  }

  // MARK: - Caching

  func add(key: String, object: T, expiry: Expiry? = nil, completion: (() -> Void)? = nil) {
    let expiry = expiry ?? config.expiry

    frontCache.add(key, object: object, expiry: expiry) { [weak self] in
      guard let weakSelf = self, backCache = weakSelf.backCache else {
        completion?()
        return
      }

      backCache.add(key, object: object, expiry: expiry) {
        completion?()
      }
    }
  }

  func object(key: String, completion: (object: T?) -> Void) {
    frontCache.object(key) { [weak self] (object: T?) in
      if let object = object {
        completion(object: object)
        return
      }

      guard let weakSelf = self, backCache = weakSelf.backCache else {
        completion(object: object)
        return
      }

      backCache.object(key) { (object: T?) in
        completion(object: object)
      }
    }
  }

  func remove(key: String, completion: (() -> Void)? = nil) {
    frontCache.remove(key) { [weak self] in
      guard let weakSelf = self, backCache = weakSelf.backCache else {
        completion?()
        return
      }

      backCache.remove(key) {
        completion?()
      }
    }
  }

  func clear(completion: (() -> Void)? = nil) {
    frontCache.clear() { [weak self] in
      guard let weakSelf = self, backCache = weakSelf.backCache else {
        completion?()
        return
      }

      backCache.clear() {
        completion?()
      }
    }
  }
}
