import Foundation

/**
 Configuration needed to create a new cache instance
 */
public struct Config {
  /// Expiry date that will be applied by default for every added object
  /// if it's not overridden in the add(key: object: expiry: completion:) method
  public let expiry: Expiry
  /// The maximum number of objects in memory the cache should hold
  public let memoryCountLimit: UInt
  /// The maximum total cost that the cache can hold before it starts evicting objects
  public let memoryTotalCostLimit: UInt
  /// Maximum size of the disk cache storage (in bytes)
  public let maxDiskSize: UInt
  /// A folder to store the disk cache contents. Defaults to a prefixed directory in Caches if nil
  public let cacheDirectory: String?

  // MARK: - Initialization

  /**
   Creates a new instance of Config.
   - Parameter expiry: Expiry date that will be applied by default for every added object
   - Parameter memoryCountLimit: The maximum number of objects the cache should hold
   - Parameter memoryTotalCostLimit: The maximum total cost that the cache can hold before it starts evicting objects
   - Parameter maxDiskSize: Maximum size of the disk cache storage (in bytes)
   - Parameter cacheDirectory: A folder to store the disk cache contents (Caches is default)
   */
  public init(expiry: Expiry = .never,
              memoryCountLimit: UInt = 0,
              memoryTotalCostLimit: UInt = 0,
              maxDiskSize: UInt = 0,
              cacheDirectory: String? = nil) {
    self.expiry = expiry
    self.memoryCountLimit = memoryCountLimit
    self.memoryTotalCostLimit = memoryTotalCostLimit
    self.maxDiskSize = maxDiskSize
    self.cacheDirectory = cacheDirectory
  }
}
