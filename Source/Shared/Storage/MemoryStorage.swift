#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#endif

public class MemoryStorage<Key: Hashable, Value>: StorageAware {
  final class WrappedKey: NSObject {
    let key: Key

    init(_ key: Key) { self.key = key }

    override var hash: Int { return key.hashValue }

    override func isEqual(_ object: Any?) -> Bool {
      guard let value = object as? WrappedKey else {
        return false
      }

      return value.key == key
    }
  }

  fileprivate let cache = NSCache<WrappedKey, MemoryCapsule>()
  // Memory cache keys
  fileprivate var keys = Set<Key>()
  /// Configuration
  fileprivate let config: MemoryConfig
    
  /// The closure to be called when the key has been removed
  public var onRemove: ((Key) -> Void)?
    
  public var didEnterBackgroundObserver: NSObjectProtocol?

  public init(config: MemoryConfig) {
    self.config = config
    self.cache.countLimit = Int(config.countLimit)
    self.cache.totalCostLimit = Int(config.totalCostLimit)
    applyExpiratonMode(self.config.expirationMode)
  }

  public func applyExpiratonMode(_ expirationMode: ExpirationMode) {
    if let didEnterBackgroundObserver = didEnterBackgroundObserver {
      NotificationCenter.default.removeObserver(didEnterBackgroundObserver)
    }
    if expirationMode == .auto {
      didEnterBackgroundObserver =
      NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification,
                                                       object: nil,
                                                       queue: nil)
      { [weak self] _ in
        guard let `self` = self else { return }
        self.removeExpiredObjects()
      }
    }
  }
    
  deinit {
    if let didEnterBackgroundObserver = didEnterBackgroundObserver {
      NotificationCenter.default.removeObserver(didEnterBackgroundObserver)
    }
  }
}

extension MemoryStorage {
  public var allKeys: [Key] {
    Array(keys)
  }

  public var allObjects: [Value] {
    allKeys.compactMap { try? object(forKey: $0) }
  }

  public func setObject(_ object: Value, forKey key: Key, expiry: Expiry? = nil) {
    let capsule = MemoryCapsule(value: object, expiry: .date(expiry?.date ?? config.expiry.date))
    
    /// MemoryLayout.size(ofValue:) return the contiguous memory footprint of the given instance , so cost is always MemoryCapsule size (8 bytes)
    let cost = MemoryLayout.size(ofValue: capsule)
    cache.setObject(capsule, forKey: WrappedKey(key), cost: cost)
    keys.insert(key)
  }

  public func removeAll() {
    cache.removeAllObjects()
    keys.removeAll()
  }

  public func removeExpiredObjects() {
    let allKeys = keys
    for key in allKeys {
      removeObjectIfExpired(forKey: key)
    }
  }

  public func removeObjectIfExpired(forKey key: Key) {
    if let capsule = cache.object(forKey: WrappedKey(key)), capsule.expiry.isExpired {
      removeObject(forKey: key)
    }
  }

  public func removeObject(forKey key: Key) {
    cache.removeObject(forKey: WrappedKey(key))
    keys.remove(key)
    onRemove?(key)
  }
    
  public func removeInMemoryObject(forKey key: Key) throws {
    cache.removeObject(forKey: WrappedKey(key))
    keys.remove(key)
  }

  public func entry(forKey key: Key) throws -> Entry<Value> {
    guard let capsule = cache.object(forKey: WrappedKey(key)) else {
      throw StorageError.notFound
    }

    guard let object = capsule.object as? Value else {
      throw StorageError.typeNotMatch
    }

    return Entry(object: object, expiry: capsule.expiry)
  }
}

public extension MemoryStorage {
  func transform<U>() -> MemoryStorage<Key, U> {
    let storage = MemoryStorage<Key, U>(config: config)
    return storage
  }
}
