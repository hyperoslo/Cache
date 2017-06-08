#if os(macOS)
  import AppKit
#else
  import UIKit
#endif

/**
 BasicHybridCache supports storing all kinds of objects, as long as they conform to
 Cachable protocol. It's two layered cache (with front and back storages)
 */
public class BasicHybridCache {
  /// A name of the cache
  public let name: String
  // Disk storage path
  public var path: String {
    return manager.backStorage.path
  }

  /// Cache manager
  let manager: CacheManager

  // MARK: - Inititalization

  /**
   Creates a new instance of BasicHybridCache.
   - Parameter name: A name of the cache
   - Parameter config: Cache configuration
   */
  public init(name: String, config: Config = Config()) {
    self.name = name
    self.manager = CacheManager(name: name, config: config)
  }
}

// MARK: - Disk cache

public extension BasicHybridCache {
  /**
   Calculates total disk cache size
   */
  func totalDiskSize() throws -> UInt64 {
    return try manager.totalDiskSize()
  }

  #if os(iOS) || os(tvOS)
  /**
   Data protection is used to store files in an encrypted format on disk and to decrypt them on demand.
   - Parameter type: File protection type
   */
  func setFileProtection( _ type: FileProtectionType) throws {
    try manager.backStorage.setFileProtection(type)
  }
  #endif

  /**
   Sets attributes on the disk cache folder.
   - Parameter attributes: Directory attributes
   */
  func setDiskCacheDirectoryAttributes(_ attributes: [FileAttributeKey : Any]) throws {
    try manager.backStorage.setDirectoryAttributes(attributes)
  }
}
