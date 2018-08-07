import Foundation
import Dispatch

/// Manage storage. Use memory storage if specified.
/// Synchronous by default. Use `async` for asynchronous operations.
public final class Storage<T> {
  /// Used for sync operations
  private let syncStorage: SyncStorage<T>
  private let asyncStorage: AsyncStorage<T>
  private let hybridStorage: HybridStorage<T>

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
    self.init(hybridStorage: hybridStorage)
  }

  /// Initialise with sync and async storages
  ///
  /// - Parameter syncStorage: Synchronous storage
  /// - Paraeter: asyncStorage: Asynchronous storage
  public init(hybridStorage: HybridStorage<T>) {
    self.hybridStorage = hybridStorage
    self.syncStorage = SyncStorage(
      storage: hybridStorage,
      serialQueue: DispatchQueue(label: "Cache.SyncStorage.SerialQueue")
    )
    self.asyncStorage = AsyncStorage(
      storage: hybridStorage,
      serialQueue: DispatchQueue(label: "Cache.AsyncStorage.SerialQueue")
    )
    subscribeToChanges(in: hybridStorage)
  }

  /// Used for async operations
  public lazy var async = self.asyncStorage

  private func subscribeToChanges(in storage: HybridStorage<T>) {
//    storage.storageObservationRegistry.addObservation { [weak self] _, change in
//      guard let strongSelf = self else { return }
//      strongSelf.storageObservationRegistry.notifyObservers(about: change, in: strongSelf)
//    }
//    keyObservationRegistry.onNewKey = { [weak self] key in
//      guard let strongSelf = self else { return }
//      storage.keyObservationRegistry.addObservation({ _, change in
//        strongSelf.keyObservationRegistry.notifyObserver(forKey: key, about: change, in: strongSelf)
//      }, forKey: key)
//    }
  }
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
    return Storage<U>(hybridStorage: hybridStorage.transform(transformer: transformer))
  }
}

extension Storage: StorageObservationRegistry {
  @discardableResult
  public func addStorageObserver<O: AnyObject>(
    _ observer: O,
    closure: @escaping (O, Storage, StorageChange) -> Void
  ) -> ObservationToken {
    return hybridStorage.addStorageObserver(observer) { [weak self] observer, _, change in
      guard let strongSelf = self else { return }
      closure(observer, strongSelf, change)
    }
  }

  public func removeAllStorageObservations() {
    hybridStorage.removeAllStorageObservations()
  }
}

extension Storage: KeyObservationRegistry {
  @discardableResult
  public func addObserver<O: AnyObject>(
    _ observer: O,
    forKey key: String,
    closure: @escaping (O, Storage, KeyChange<T>) -> Void
  ) -> ObservationToken {
    return hybridStorage.addObserver(observer, forKey: key) { [weak self] observer, _ , change in
      guard let strongSelf = self else { return }
      closure(observer, strongSelf, change)
    }
  }

  public func removeObservation(forKey key: String) {
    hybridStorage.removeObservation(forKey: key)
  }

  public func removeAllKeyObservations() {
    hybridStorage.removeAllKeyObservations()
  }
}
