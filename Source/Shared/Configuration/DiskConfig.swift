import Foundation

public struct DiskConfig {
  /// The name of disk storage, this will be used as folder name within directory
  public let name: String
  /// Expiry date that will be applied by default for every added object
  /// if it's not overridden in the add(key: object: expiry: completion:) method
  public let expiry: Expiry

  /// ExpirationMode that will be applied  for every added object
  public let expirationMode: ExpirationMode

  /// Maximum size of the disk cache storage (in bytes)
  public let maxSize: UInt
  /// A folder to store the disk cache contents. Defaults to a prefixed directory in Caches if nil
  public let directory: URL?
  /// Data protection is used to store files in an encrypted format on disk and to decrypt them on demand.
  public let protectionType: FileProtectionType?

  public init(name: String,
              expiry: Expiry = .never,
              expirationMode: ExpirationMode = .auto,
              maxSize: UInt = 0, directory: URL? = nil,
              protectionType: FileProtectionType? = nil) {
    self.name = name
    self.expiry = expiry
    self.expirationMode  = expirationMode
    
    self.maxSize = maxSize
    self.directory = directory
    self.protectionType = protectionType
  }
}
