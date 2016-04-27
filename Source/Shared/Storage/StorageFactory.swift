/**
 A place to register and retrieve a cache storage by type.
 */
public class StorageFactory {

  /// Default storage type
  private static var DefaultStorage: StorageAware.Type = MemoryStorage.self

  /// Dictionary of default storages
  private static var defaultStorages: [String: StorageAware.Type] = [
    StorageKind.Memory.name : MemoryStorage.self,
    StorageKind.Disk.name : DiskStorage.self
  ]

  /// Dictionary of storages
  private static var storages = defaultStorages

  // MARK: - Factory

  /**
   Registers new storage for the specified kind.

   - Parameter kind: Storage kind
   - Parameter storage: StorageAware type
   */
  static func register<T: StorageAware>(kind: StorageKind, storage: T.Type) {
    storages[kind.name] = storage
  }

  /**
   Creates new storage with the specified name and maximum size.

   - Parameter name: A name of the storage
   - Parameter kind: Storage kind
   - Parameter maxSize: Maximum size of the cache storage
   - Returns: New storage
   */
  static func resolve(name: String, kind: StorageKind, maxSize: UInt = 0) -> StorageAware {
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
