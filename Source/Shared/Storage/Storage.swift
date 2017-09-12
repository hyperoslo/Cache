import Foundation

public class Storage {
  private let internalStorage: StorageAware

  /// Initialize storage with configuration options.
  ///
  /// - Parameters:
  ///   - diskConfig: Configuration for disk storage
  ///   - memoryConfig: Optional. Pass confi if you want memory cache
  /// - Throws: Throw CacheError if any.
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

extension Storage: StorageAware {
  public func entry<T: Codable>(forKey key: String) throws -> Entry<T> {
    return try internalStorage.entry(forKey: key)
  }

  public func removeObject(forKey key: String) throws {
    try internalStorage.removeObject(forKey: key)
  }

  public func setObject<T: Codable>(_ object: T, forKey key: String) throws {
    try internalStorage.setObject(object, forKey: key)
  }

  public func removeAll() throws {
    try internalStorage.removeAll()
  }

  public func removeExpiredObjects() throws {
    try internalStorage.removeExpiredObjects()
  }
}
