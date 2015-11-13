import Foundation

public class Cache<T: Cachable> {

  public let name: String

  let config: Config
  let kinds: [CacheKind]

  // MARK: - Inititalization

  public init(name: String, kinds: [CacheKind] = [.Memory, .Disk],
    config: Config = Config.defaultConfig) {
      self.name = name
      self.kinds = kinds
      self.config = config
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