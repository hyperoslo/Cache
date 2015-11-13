import Foundation

public class Cache<T: Cachable> {

  public let name: String

  let config: Config
  let frontCache: CacheAware
  var backCache: CacheAware?

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

  func add(key: String, object: T, expiry: Expiry = .Never, completion: (() -> Void)?) {

  }

  func object(key: String, completion: (object: T?) -> Void) {

  }

  func remove(key: String, completion: (() -> Void)?) {

  }

  func clear(completion: (() -> Void)?) {

  }
}