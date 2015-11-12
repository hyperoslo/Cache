import Foundation

private struct Keys {
  static let value = "value"
  static let expirationDate = "expirationDate"
}

public class CacheObject<T: AnyObject>: NSObject, NSCoding {

  public let value: T
  public let expirationDate: NSDate

  public var expired: Bool {
    return expirationDate.timeIntervalSinceNow < 0
  }

  // MARK: - Initialization

  public init(value: T, expirationDate: NSDate) {
    self.value = value
    self.expirationDate = expirationDate
  }

  public required init?(coder aDecoder: NSCoder) {
    value = aDecoder.decodeObjectForKey(Keys.value) as! T
    expirationDate = aDecoder.decodeObjectForKey(Keys.expirationDate) as! NSDate

    super.init()
  }

  // MARK: - NSCoding

  public func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(value, forKey: Keys.value)
    aCoder.encodeObject(expirationDate, forKey: Keys.expirationDate)
  }
}
