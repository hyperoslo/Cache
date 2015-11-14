public struct Config {

  public let frontKind: CacheKind
  public let backKind: CacheKind?
  public let expiry: Expiry
  public let maxSize: UInt

  // MARK: - Initialization

  public init(frontKind: CacheKind, backKind: CacheKind?, expiry: Expiry, maxSize: UInt) {
    self.frontKind = frontKind
    self.backKind = backKind
    self.expiry = expiry
    self.maxSize = maxSize
  }
}

// MARK: - Defaults

extension Config {

  public static var defaultConfig: Config {
    return Config(
      frontKind: .Memory,
      backKind: .Disk,
      expiry: .Never,
      maxSize: 0)
  }
}