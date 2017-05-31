import Foundation

/**
 Configuration needed to create a new `MemoryStorage` instance
 */
public protocol MemoryStorageConfig {
  /// Maximum amount of items to store in memory
  var maxObjectsInMemory: Int { get }
}

/**
 Configuration needed to create a new `DiskStorage` instance
 */
public protocol DiskStorageConfig {
  /// Maximum size of the cache storage
  var maxSize: UInt { get }
  /// (optional) A folder to store the disk cache contents. Defaults to a prefixed directory in Caches if nil
  var cacheDirectory: String? { get }
  /// Data protection is used to store files in an encrypted format on disk and to decrypt them on demand
  var fileProtectionType: FileProtectionType { get }
}

/**
 Configuration needed to create a new cache instance
 */
public struct Config: MemoryStorageConfig, DiskStorageConfig {
  /// Expiry date that will be applied by default for every added object
  /// if it's not overridden in the add(key: object: expiry: completion:) method
  public let expiry: Expiry
  /// Maximum amount of items to store in memory
  public let maxObjectsInMemory: Int
  /// Maximum size of the cache storage
  public let maxSize: UInt
  /// (optional) A folder to store the disk cache contents. Defaults to a prefixed directory in Caches if nil
  public let cacheDirectory: String?
  /// Data protection is used to store files in an encrypted format on disk and to decrypt them on demand
  public let fileProtectionType: FileProtectionType

  // MARK: - Initialization

  /**
   Creates a new instance of Config.
   - Parameter frontKind: Front cache type
   - Parameter backKind: Back cache type
   - Parameter expiry: Expiry date that will be applied by default for every added object
   - Parameter maxSize: Maximum size of the cache storage
   - Parameter maxObjects: Maximum amount of objects to be stored in memory
   */
  public init(expiry: Expiry = .never,
              maxObjectsInMemory: Int = 0,
              maxSize: UInt = 0,
              cacheDirectory: String? = nil,
              fileProtectionType: FileProtectionType = .none) {
    self.expiry = expiry
    self.maxObjectsInMemory = maxObjectsInMemory
    self.maxSize = maxSize
    self.cacheDirectory = cacheDirectory
    self.fileProtectionType = fileProtectionType
  }
}
