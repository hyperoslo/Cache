/**
 A place to register and retrieve a cache storage by type.
 */
public final class StorageFactory {

  /// Default storage type
  fileprivate static var DefaultStorage: StorageAware.Type = MemoryStorage.self

  /// Dictionary of default storages
  fileprivate static var defaultStorages: [String: StorageAware.Type] = [
    StorageKind.memory.name : MemoryStorage.self,
    StorageKind.disk.name : DiskStorage.self
  ]

  /// Dictionary of storages
  fileprivate static var storages = defaultStorages

  // MARK: - Factory

  /**
   Registers new storage for the specified kind.

   - Parameter kind: Storage kind
   - Parameter storage: StorageAware type
   */
  static func register<T: StorageAware>(_ kind: StorageKind, storage: T.Type) {
    storages[kind.name] = storage
  }

  /**
   Creates new storage with the specified name and maximum size.

   - Parameter name: A name of the storage
   - Parameter kind: Storage kind
   - Parameter maxSize: Maximum size of the cache storage
   - Returns: New storage
   */
  static func resolve(_ name: String, kind: StorageKind, maxSize: UInt = 0) -> StorageAware {
    let StorageType: StorageAware.Type = storages[kind.name] ?? DefaultStorage
    return StorageType.init(name: name, maxSize: maxSize)
  }

  /**
   Resets storage container to defaults.
   */
  static func reset() {
    storages = defaultStorages
  }
}
