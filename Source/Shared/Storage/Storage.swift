import Foundation
import Dispatch

/// Manage storage. Use memory storage if specified.
/// Synchronous by default. Use `async` for asynchronous operations.
public final class Storage<Key: Hashable, Value> {
  /// Used for sync operations
  private let syncStorage: SyncStorage<Key, Value>
  private let asyncStorage: AsyncStorage<Key, Value>
  private let hybridStorage: HybridStorage<Key, Value>

  /// Initialize storage with configuration options.
  ///
  /// - Parameters:
  ///   - diskConfig: Configuration for disk storage
  ///   - memoryConfig: Optional. Pass config if you want memory cache
  /// - Throws: Throw StorageError if any.
    public convenience init(diskConfig: DiskConfig, memoryConfig: MemoryConfig, fileManager: FileManager, transformer: Transformer<Value>) throws {
    let disk = try DiskStorage<Key, Value>(config: diskConfig, fileManager: fileManager, transformer: transformer)
    let memory = MemoryStorage<Key, Value>(config: memoryConfig)
    let hybridStorage = HybridStorage(memoryStorage: memory, diskStorage: disk)
    self.init(hybridStorage: hybridStorage)
  }

  /// Initialise with sync and async storages
  ///
  /// - Parameter syncStorage: Synchronous storage
  /// - Paraeter: asyncStorage: Asynchronous storage
  public init(hybridStorage: HybridStorage<Key, Value>) {
    self.hybridStorage = hybridStorage
    self.syncStorage = SyncStorage(
      storage: hybridStorage,
      serialQueue: DispatchQueue(label: "Cache.SyncStorage.SerialQueue")
    )
    self.asyncStorage = AsyncStorage(
      storage: hybridStorage,
      serialQueue: DispatchQueue(label: "Cache.AsyncStorage.SerialQueue")
    )
  }

  /// Used for async operations
  public lazy var async = self.asyncStorage
}

extension Storage: StorageAware {
  public func removeInMemoryObject(forKey key: Key) throws {
    try self.syncStorage.removeInMemoryObject(forKey: key)
  }
    
  public var allKeys: [Key] {
    self.syncStorage.allKeys
  }

  public var allObjects: [Value] {
    self.syncStorage.allObjects
  }

  public func entry(forKey key: Key) throws -> Entry<Value> {
    return try self.syncStorage.entry(forKey: key)
  }

  public func removeObject(forKey key: Key) throws {
    try self.syncStorage.removeObject(forKey: key)
  }

  public func setObject(_ object: Value, forKey key: Key, expiry: Expiry? = nil) throws {
    try self.syncStorage.setObject(object, forKey: key, expiry: expiry)
  }

  public func removeAll() throws {
    try self.syncStorage.removeAll()
  }

  public func removeExpiredObjects() throws {
    try self.syncStorage.removeExpiredObjects()
  }

  public func removeExpiredObjects(expiryPeriod: TimeInterval? = nil) throws {
    try self.syncStorage.removeExpiredObjects(expiryPeriod: expiryPeriod)
  }
}

public extension Storage {
  func transform<U>(transformer: Transformer<U>) -> Storage<Key, U> {
    return Storage<Key, U>(hybridStorage: hybridStorage.transform(transformer: transformer))
  }
}

extension Storage: StorageObservationRegistry {
  @discardableResult
  public func addStorageObserver<O: AnyObject>(
    _ observer: O,
    closure: @escaping (O, Storage, StorageChange<Key>) -> Void
  ) -> ObservationToken {
    return hybridStorage.addStorageObserver(observer) { [weak self] observer, _, change in
      guard let strongSelf = self else { return }
      closure(observer, strongSelf, change)
    }
  }

  public func removeAllStorageObservers() {
    hybridStorage.removeAllStorageObservers()
  }
}

extension Storage: KeyObservationRegistry {
  @discardableResult
  public func addObserver<O: AnyObject>(
    _ observer: O,
    forKey key: Key,
    closure: @escaping (O, Storage, KeyChange<Value>) -> Void
  ) -> ObservationToken {
    return hybridStorage.addObserver(observer, forKey: key) { [weak self] observer, _, change in
      guard let strongSelf = self else { return }
      closure(observer, strongSelf, change)
    }
  }

  public func removeObserver(forKey key: Key) {
    hybridStorage.removeObserver(forKey: key)
  }

  public func removeAllKeyObservers() {
    hybridStorage.removeAllKeyObservers()
  }
}

public extension Storage {
  /// Returns the total size of the DiskStorage of the underlying HybridStorage in bytes.
  var totalDiskStorageSize: Int? {
    return self.hybridStorage.diskStorage.totalSize
  }
}
