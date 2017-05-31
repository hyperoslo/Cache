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
  /// Maximum size of the disk cache storage
  public let maxDiskSize: UInt
  /// A folder to store the disk cache contents. Defaults to a prefixed directory in Caches if nil
  public let cacheDirectory: String?
  /// Data protection is used to store files in an encrypted format on disk and to decrypt them on demand.
  //https://developer.apple.com/library/content/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/StrategiesforImplementingYourApp/StrategiesforImplementingYourApp.html#//apple_ref/doc/uid/TP40007072-CH5-SW21
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
              maxDiskSize: UInt = 0,
              cacheDirectory: String? = nil,
              fileProtectionType: FileProtectionType = .none) {
    self.expiry = expiry
    self.maxObjectsInMemory = maxObjectsInMemory
    self.maxDiskSize = maxDiskSize
    self.cacheDirectory = cacheDirectory
    self.fileProtectionType = fileProtectionType
  }
}
