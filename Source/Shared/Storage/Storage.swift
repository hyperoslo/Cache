import Foundation

/// Manage storage. Use memory storage if specified.
/// Synchronous by default. Use `async` for asynchronous operations.
public class Storage {
  /// Used for sync operations
  fileprivate let sync: StorageAware

  /// Storage used internally by both sync and async storages
  private let interalStorage: StorageAware

  /// Initialize storage with configuration options.
  ///
  /// - Parameters:
  ///   - diskConfig: Configuration for disk storage
  ///   - memoryConfig: Optional. Pass confi if you want memory cache
  /// - Throws: Throw StorageError if any.
  public required init(diskConfig: DiskConfig, memoryConfig: MemoryConfig? = nil) throws {
    // Disk or Hybrid
    let storage: StorageAware
    let disk = try DiskStorage(config: diskConfig)

    if let memoryConfig = memoryConfig {
      let memory = MemoryStorage(config: memoryConfig)
      storage = HybridStorage(memoryStorage: memory, diskStorage: disk)
    } else {
      storage = disk
    }

    // Wrapper
    self.interalStorage = TypeWrapperStorage(storage: storage)

    // Sync
    self.sync = SyncStorage(storage: interalStorage,
                            serialQueue: DispatchQueue(label: "Cache.SyncStorage.SerialQueue"))
  }

  /// Used for async operations
  public lazy var async: AsyncStorage = AsyncStorage(storage: self.interalStorage,
                                                     serialQueue: DispatchQueue(label: "Cache.AsyncStorage.SerialQueue"))
}

extension Storage: StorageAware {
  public func entry<T: Codable>(ofType type: T.Type, forKey key: String) throws -> Entry<T> {
    return try self.sync.entry(ofType: type, forKey: key)
  }

  public func removeObject(forKey key: String) throws {
    try self.sync.removeObject(forKey: key)
  }

  public func setObject<T: Codable>(_ object: T, forKey key: String,
                                    expiry: Expiry? = nil) throws {
    try self.sync.setObject(object, forKey: key, expiry: expiry)
  }

  public func removeAll() throws {
    try self.sync.removeAll()
  }

  public func removeExpiredObjects() throws {
    try self.sync.removeExpiredObjects()
  }
}
