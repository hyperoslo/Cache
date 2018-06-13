import Foundation
import Dispatch

/// Manage storage. Use memory storage if specified.
/// Synchronous by default. Use `async` for asynchronous operations.
public class Storage2<T> {
  /// Used for sync operations
  let syncStorage: SyncStorage2<T>
  let asyncStorage: AsyncStorage2<T>

  /// Initialize storage with configuration options.
  ///
  /// - Parameters:
  ///   - diskConfig: Configuration for disk storage
  ///   - memoryConfig: Optional. Pass config if you want memory cache
  /// - Throws: Throw StorageError if any.
  public convenience init(diskConfig: DiskConfig, memoryConfig: MemoryConfig, transformer: Transformer<T>) throws {
    let disk = try DiskStorage2(config: diskConfig, transformer: transformer)
    let memory = MemoryStorage2<T>(config: memoryConfig)

    let hybridStorage = HybridStorage2(memoryStorage: memory, diskStorage: disk)
    let syncStorage = SyncStorage2(
      innerStorage: hybridStorage,
      serialQueue: DispatchQueue(label: "Cache.SyncStorage.SerialQueue")
    )

    let asyncStorage = AsyncStorage2(
      storage: hybridStorage,
      serialQueue: DispatchQueue(label: "Cache.AsyncStorage.SerialQueue")
    )

    self.init(syncStorage: syncStorage, asyncStorage: asyncStorage)
  }

  /// Initialise with sync and async storages
  ///
  /// - Parameter syncStorage: Synchronous storage
  /// - Paraeter: asyncStorage: Asynchronous storage
  public required init(syncStorage: SyncStorage2<T>, asyncStorage: AsyncStorage2<T>) {
    self.syncStorage = syncStorage
    self.asyncStorage = asyncStorage
  }

  /// Used for async operations
  public lazy var async = self.asyncStorage
}

extension Storage2: StorageAware2 {
  public func entry(forKey key: String) throws -> Entry2<T> {
    return try self.syncStorage.entry(forKey: key)
  }

  public func removeObject(forKey key: String) throws {
    try self.syncStorage.removeObject(forKey: key)
  }

  public func setObject(_ object: T, forKey key: String, expiry: Expiry? = nil) throws {
    try self.syncStorage.setObject(object, forKey: key, expiry: expiry)
  }

  public func removeAll() throws {
    try self.syncStorage.removeAll()
  }

  public func removeExpiredObjects() throws {
    try self.syncStorage.removeExpiredObjects()
  }
}

public extension Storage2 {
  func support<U>(transformer: Transformer<U>) -> Storage2<U> {
    let storage = Storage2<U>(
      syncStorage: syncStorage.support(transformer: transformer),
      asyncStorage: asyncStorage.support(transformer: transformer)
    )
    return storage
  }
}
