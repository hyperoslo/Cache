import Foundation

public class Storage2 {
  private let internalStorage: StorageAware2

  /// Initialize storage with configuration options.
  ///
  /// - Parameters:
  ///   - diskConfig: Configuration for disk storage
  ///   - memoryConfig: Optional. Pass confi if you want memory cache
  /// - Throws: Throw CacheError if any.
  public required init(diskConfig: DiskConfig2, memoryConfig: MemoryConfig2? = nil) throws {
    let disk = try DiskStorage2(config: diskConfig)

    if let memoryConfig = memoryConfig {
      let memory = MemoryStorage2(config: memoryConfig)
      internalStorage = HybridStorage2(memoryStorage: memory, diskStorage: disk)
    } else {
      internalStorage = disk
    }
  }
}

extension Storage2: StorageAware2 {
  public func entry<T: Codable>(forKey key: String) throws -> Entry2<T> {
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
