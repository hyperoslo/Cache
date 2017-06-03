import Foundation

/**
 Configuration needed to create a new cache instance
 */
public struct Config {
  /// Expiry date that will be applied by default for every added object
  /// if it's not overridden in the add(key: object: expiry: completion:) method
  public let expiry: Expiry
  /// Maximum amount of items to store in memory
  public let maxObjectsInMemory: Int
  /// Maximum size of the disk cache storage (in bytes)
  public let maxDiskSize: UInt
  /// A folder to store the disk cache contents. Defaults to a prefixed directory in Caches if nil
  public let cacheDirectory: String?

  // MARK: - Initialization

  /**
   Creates a new instance of Config.
   - Parameter expiry: Expiry date that will be applied by default for every added object
   - Parameter maxObjectsInMemory: Maximum amount of items to store in memory
   - Parameter maxDiskSize: Maximum size of the disk cache storage (in bytes)
   - Parameter cacheDirectory: A folder to store the disk cache contents (Caches is default)
   */
  public init(expiry: Expiry = .never,
              maxObjectsInMemory: Int = 0,
              maxDiskSize: UInt = 0,
              cacheDirectory: String? = nil) {
    self.expiry = expiry
    self.maxObjectsInMemory = maxObjectsInMemory
    self.maxDiskSize = maxDiskSize
    self.cacheDirectory = cacheDirectory
  }
}
