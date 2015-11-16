import Foundation

public class Cache<T: Cachable>: CacheAware {

  // MARK: - Initialization

  public required init(name: String, maxSize: UInt = 0) {
    super.init(name: name, maxSize: maxSize)
  }

  // MARK: - CacheAware

  public override func add(key: String, object: T, expiry: Expiry = .Never, completion: (() -> Void)? = nil) {
    super.add(key, object: object, expiry: expiry, completion: completion)
  }

  public override func object(key: String, completion: (object: T?) -> Void) {
    super.object(key, completion: completion)
  }

  public override func remove(key: String, completion: (() -> Void)? = nil) {
    dispatch_async(writeQueue) { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      weakSelf.cache.removeObjectForKey(key)
      completion?()
    }
  }

  public func removeIfExpired(key: String, completion: (() -> Void)?) {
    dispatch_async(writeQueue) { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      if let capsule = weakSelf.cache.objectForKey(key) as? Capsule {
        weakSelf.removeIfExpired(key, capsule: capsule, completion: completion)
      } else {
        completion?()
      }
    }
  }

  public func clear(completion: (() -> Void)? = nil) {
    dispatch_async(writeQueue) { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      weakSelf.cache.removeAllObjects()
      completion?()
    }
  }

  // MARK: - Helpers

  func removeIfExpired(key: String, capsule: Capsule, completion: (() -> Void)? = nil) {
    if capsule.expired {
      remove(key, completion: completion)
    } else {
      completion?()
    }
  }
}
