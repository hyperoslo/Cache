import Foundation

/// Manage storage. Use memory storage if specified.
public class Storage {
  let internalStorage: StorageAware

  /// Initialize storage with configuration options.
  ///
  /// - Parameters:
  ///   - diskConfig: Configuration for disk storage
  ///   - memoryConfig: Optional. Pass confi if you want memory cache
  /// - Throws: Throw StorageError if any.
  public required init(diskConfig: DiskConfig, memoryConfig: MemoryConfig? = nil) throws {
    let storage: StorageAware
    let disk = try DiskStorage(config: diskConfig)

    if let memoryConfig = memoryConfig {
      let memory = MemoryStorage(config: memoryConfig)
      storage = HybridStorage(memoryStorage: memory, diskStorage: disk)
    } else {
      storage = disk
    }

    self.internalStorage = TypeWrapperStorage(storage: storage)
  }

  /// Return all sync storage
  public lazy var sync: SyncStorage = SyncStorage(storage: self.internalStorage)

  /// Return all async storage
  public lazy var async: AsyncStorage = AsyncStorage(storage: self.internalStorage)
}
