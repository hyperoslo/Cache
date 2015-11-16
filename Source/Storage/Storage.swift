import Foundation

public class Storage<T: Cachable>: CacheAware {

  private var storage: StorageAware

  // MARK: - Initialization

  public required init(kind: StorageKind, name: String, maxSize: UInt = 0) {
    storage = StorageFactory.resolve(name, kind: kind, maxSize: maxSize)
  }

  // MARK: - CacheAware

  public func add<T: Cachable>(key: String, object: T, expiry: Expiry = .Never, completion: (() -> Void)? = nil) {
    storage.add(key, object: object, expiry: expiry, completion: completion)
  }

  public func object<T: Cachable>(key: String, completion: (object: T?) -> Void) {
    storage.object(key, completion: completion)
  }

  public func remove(key: String, completion: (() -> Void)? = nil) {
    storage.remove(key, completion: completion)
  }

  public func removeIfExpired(key: String, completion: (() -> Void)?) {
    storage.removeIfExpired(key, completion: completion)
  }

  public func clear(completion: (() -> Void)? = nil) {
    storage.clear(completion)
  }
}
