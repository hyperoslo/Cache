import Foundation

public class Cache<T: Cachable> {

  let name: String
  let config: Config

  public init(name: String, config: Config = Config.defaultConfig) {
    self.name = name
    self.config = config
  }

  func add(key: String, object: T, expiry: Expiry = .Never, completion: (() -> Void)?) {

  }

  func object(key: String, completion: (object: T?) -> Void) {

  }

  func remove(key: String, completion: (() -> Void)?) {

  }

  func clear(completion: (() -> Void)?) {

  }
}