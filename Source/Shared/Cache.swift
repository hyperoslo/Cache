import Foundation

public class Cache<T: Cachable>: BasicHybridCache {

  public override init(name: String, config: Config = Config.defaultConfig) {
    super.init(name: name, config: config)
  }

  // MARK: - Caching

  public override func add(key: String, object: T, expiry: Expiry? = nil, completion: (() -> Void)? = nil) {
    super.add(key, object: object, expiry: expiry, completion: completion)
  }

  public override func object(key: String, completion: (object: T?) -> Void) {
    super.object(key, completion: completion)
  }
}
