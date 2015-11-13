public enum CacheKind {
  case Memory, Disk
}

public struct Config {

  public let kinds: [CacheKind]
  public let expiry: Expiry
  public let maxSize: UInt

  // MARK: - Initialization

  public init(kinds: [CacheKind] = [.Memory, .Disk],
    expiry: Expiry = .Never,
    maxSize: UInt = 0) {
      self.kinds = kinds
      self.expiry = expiry
      self.maxSize = maxSize
  }
}

// MARK: - Defaults

extension Config {

  public static var defaultConfig: Config {
    return Config()
  }
}