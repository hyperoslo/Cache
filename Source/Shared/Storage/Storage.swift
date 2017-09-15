import Foundation

/// Manage storage. Use memory storage if specified.
public class Storage {
  private let internalStorage: StorageAware

  /// Initialize storage with configuration options.
  ///
  /// - Parameters:
  ///   - diskConfig: Configuration for disk storage
  ///   - memoryConfig: Optional. Pass confi if you want memory cache
  /// - Throws: Throw StorageError if any.
  public required init(diskConfig: DiskConfig, memoryConfig: MemoryConfig? = nil) throws {
    let disk = try DiskStorage(config: diskConfig)

    if let memoryConfig = memoryConfig {
      let memory = MemoryStorage(config: memoryConfig)
      internalStorage = HybridStorage(memoryStorage: memory, diskStorage: disk)
    } else {
      internalStorage = disk
    }
  }
}
