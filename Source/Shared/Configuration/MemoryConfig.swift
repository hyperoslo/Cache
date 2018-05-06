import Foundation

public struct MemoryConfig {
  /// Expiry date that will be applied by default for every added object
  /// if it's not overridden in the add(key: object: expiry: completion:) method
  public let expiry: Expiry
  /// The maximum number of objects in memory the cache should hold. 0 means no limit.
  public let countLimit: UInt

  public init(expiry: Expiry = .never, countLimit: UInt = 0) {
    self.expiry = expiry
    self.countLimit = countLimit
  }

  // MARK: - Deprecated
  @available(*, deprecated,
  message: "Use init(expiry:countLimit:) instead.",
  renamed: "init(expiry:countLimit:)")
  public init(expiry: Expiry = .never, countLimit: UInt = 0, totalCostLimit: UInt = 0) {
    self.init(expiry: expiry, countLimit: countLimit)
  }
}
