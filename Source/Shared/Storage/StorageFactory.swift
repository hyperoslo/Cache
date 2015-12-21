public class StorageFactory {

  private static var DefaultStorage: StorageAware.Type = MemoryStorage.self

  private static var defaultStorages: [String: StorageAware.Type] = [
    StorageKind.Memory.name : MemoryStorage.self,
    StorageKind.Disk.name : DiskStorage.self
  ]

  private static var storages = defaultStorages

  // MARK: - Factory

  static func register<T: StorageAware>(kind: StorageKind, storage: T.Type) {
    storages[kind.name] = storage
  }

  static func resolve(name: String, kind: StorageKind, maxSize: UInt = 0) -> StorageAware {
    let StorageType: StorageAware.Type = storages[kind.name] ?? DefaultStorage
    return StorageType.init(name: name, maxSize: maxSize)
  }

  static func reset() {
    storages = defaultStorages
  }
}