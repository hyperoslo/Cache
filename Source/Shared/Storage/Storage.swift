import Foundation
import Dispatch

/// Manage storage. Use memory storage if specified.
/// Synchronous by default. Use `async` for asynchronous operations.
public class Storage<T> {
  /// Used for sync operations
  let syncStorage: SyncStorage<T>
  let asyncStorage: AsyncStorage<T>

  /// Initialize storage with configuration options.
  ///
  /// - Parameters:
  ///   - diskConfig: Configuration for disk storage
  ///   - memoryConfig: Optional. Pass config if you want memory cache
  /// - Throws: Throw StorageError if any.
  public convenience init(diskConfig: DiskConfig, memoryConfig: MemoryConfig, transformer: Transformer<T>) throws {
    let disk = try DiskStorage(config: diskConfig, transformer: transformer)
    let memory = MemoryStorage<T>(config: memoryConfig)

    let hybridStorage = HybridStorage(memoryStorage: memory, diskStorage: disk)
    let syncStorage = SyncStorage(
      storage: hybridStorage,
      serialQueue: DispatchQueue(label: "Cache.SyncStorage.SerialQueue")
    )

    let asyncStorage = AsyncStorage(
      storage: hybridStorage,
      serialQueue: DispatchQueue(label: "Cache.AsyncStorage.SerialQueue")
    )

    self.init(syncStorage: syncStorage, asyncStorage: asyncStorage)
  }

  /// Initialise with sync and async storages
  ///
  /// - Parameter syncStorage: Synchronous storage
  /// - Paraeter: asyncStorage: Asynchronous storage
  public required init(syncStorage: SyncStorage<T>, asyncStorage: AsyncStorage<T>) {
    self.syncStorage = syncStorage
    self.asyncStorage = asyncStorage
  }

  /// Used for async operations
  public lazy var async = self.asyncStorage
}

extension Storage: StorageAware {
  public func entry(forKey key: String) throws -> Entry<T> {
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

public extension Storage {
  func transform<U>(transformer: Transformer<U>) -> Storage<U> {
    let storage = Storage<U>(
      syncStorage: syncStorage.transform(transformer: transformer),
      asyncStorage: asyncStorage.transform(transformer: transformer)
    )
    return storage
  }
}
