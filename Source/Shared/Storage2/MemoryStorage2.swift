import Foundation

/**
 Memory cache storage based on NSCache.
 */
final class MemoryStorage2 {
  /// Memory cache instance
  fileprivate let cache = NSCache<NSString, Capsule>()
  // Memory cache keys
  fileprivate var keys = Set<String>()
  /// Configuration
  private let config: MemoryConfig2

  // MARK: - Initialization

  init(config: MemoryConfig2) {
    self.config = config
  }
}

extension MemoryStorage2: StorageAware2 {
  func object<T: Codable>(forKey key: String) -> T? {
    return entry(forKey: key)?.object
  }

  func entry<T: Codable>(forKey key: String) -> Entry2<T>? {
    guard let capsule = cache.object(forKey: key as NSString) else {
      return nil
    }

    guard let object = capsule.object as? T else {
      return nil
    }

    return Entry2(object: object, expiry: Expiry.date(capsule.expiryDate))
  }

  func removeObject(forKey key: String) {
    cache.removeObject(forKey: key as NSString)
    keys.remove(key)
  }

  func setObject<T: Codable>(_ object: T, forKey key: String) {
    let capsule = Capsule(value: object, expiry: config.expiry)
    cache.setObject(capsule, forKey: key as NSString)
    keys.insert(key)
  }

  func removeAll() {
    cache.removeAllObjects()
    keys.removeAll()
  }

  func removeExpiredObjects() {
    let allKeys = keys
    for key in allKeys {
      removeObjectIfExpired(forKey: key)
    }
  }
}

fileprivate extension MemoryStorage2 {
  /**
   Removes the object from the cache if it's expired.
   - Parameter key: Unique key to identify the object in the cache
   */
  func removeObjectIfExpired(forKey key: String) {
    if let capsule = cache.object(forKey: key as NSString), capsule.isExpired {
      removeObject(forKey: key)
    }
  }
}
