public struct Config {

  public let expiry: Expiry
  public let maxSize: UInt

  // MARK: - Initialization

  public init(expiry: Expiry = .Never, maxSize: UInt = 0) {
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