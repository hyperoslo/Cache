import Foundation

/**
 Memory cache storage based on NSCache.
 */
final class MemoryStorage {
  /// Memory cache instance
  fileprivate let cache = NSCache<NSString, Capsule>()
  // Memory cache keys
  fileprivate var keys = Set<String>()
  /// Configuration
  private let config: MemoryConfig

  // MARK: - Initialization

  init(config: MemoryConfig) {
    self.config = config
  }
}

extension MemoryStorage: StorageAware {
  func entry<T: Codable>(forKey key: String) throws -> Entry<T> {
    guard let capsule = cache.object(forKey: key as NSString) else {
      throw CacheError.notFound
    }

    guard let object = capsule.object as? T else {
      throw CacheError.typeNotMatch
    }

    return Entry(object: object, expiry: Expiry.date(capsule.expiryDate))
  }

  func removeObject(forKey key: String) {
    cache.removeObject(forKey: key as NSString)
    keys.remove(key)
  }

  func setObject<T: Codable>(_ object: T, forKey key: String, expiry: Expiry? = nil) {
    let capsule = Capsule(value: object, expiry: expiry ?? config.expiry)
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

extension MemoryStorage {
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
