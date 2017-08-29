import Foundation

/// Alternative to `NSCoding` protocol for Swift structs and enums
public protocol Coding: Cachable {
  func encode(with aCoder: NSCoder)
  init?(coder aDecoder: NSCoder)
}

public extension Coding {
  /**
   Creates an instance from Data.
   - Parameter data: Data to decode from
   - Returns: An optional CacheType
   */
  static func decode(_ data: Data) -> Self? {
    let capsule = NSKeyedUnarchiver.unarchiveObject(with: data) as? CodingCapsule
    return (capsule?.helper as? CodingHelper<Self>)?.value
  }

  /**
   Encodes an instance to Data.
   - Returns: Optional Data
   */
  func encode() -> Data? {
    let helper = CodingHelper(value: self)
    let capsule = CodingCapsule(helper: helper)
    return NSKeyedArchiver.archivedData(withRootObject: capsule)
  }
}

public extension Cachable where Self: NSCoding {
  /**
   Creates an instance from Data.
   - Parameter data: Data to decode from
   - Returns: An optional CacheType
   */
  static func decode(_ data: Data) -> Self? {
    return NSKeyedUnarchiver.unarchiveObject(with: data) as? Self
  }

  /**
   Encodes an instance to Data.
   - Returns: Optional Data
   */
  func encode() -> Data? {
    return NSKeyedArchiver.archivedData(withRootObject: self)
  }
}

// MARK: - Helpers

/// `CodingHelper` is a wrapper around generic `Coding` protocol,
/// to make it play well with `CodingCapsule`, which is NSObject.
private final class CodingHelper<T: Coding>: NSCoding {
  let value: T

  /**
   Creates an instance of CodingHelper.
   - Parameter data: Coding instance
   */
  init(value: T) {
    self.value = value
  }

  convenience init?(coder aDecoder: NSCoder) {
    guard let value = T(coder: aDecoder) else {
      return nil
    }
    self.init(value: value)
  }

  func encode(with aCoder: NSCoder) {
    value.encode(with: aCoder)
  }
}

/// Object to wrap value conforming to non-class `Coding` protocol
/// It passes `NSCoder` down to `Coding` object where actual encoding and decoding happen.
private final class CodingCapsule: NSObject, NSCoding {
  static let key = "helper"
  let helper: NSCoding

  /**
   Creates an instance of CodingCapsule.
   - Parameter data: NSCoding instance
   */
  init(helper: NSCoding) {
    self.helper = helper
  }

  convenience init?(coder aDecoder: NSCoder) {
    guard let type = aDecoder.decodeObject(forKey: CodingCapsule.key) as? String else {
      return nil
    }
    guard let helper = (NSClassFromString(type) as? NSCoding.Type)?.init(coder: aDecoder) else {
      return nil
    }
    self.init(helper: helper)
  }

  func encode(with aCoder: NSCoder) {
    helper.encode(with: aCoder)
    aCoder.encode(NSStringFromClass(type(of: helper)), forKey: CodingCapsule.key)
  }
}
