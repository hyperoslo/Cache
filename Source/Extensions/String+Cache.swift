import Foundation

// MARK: - Cachable

extension String: Cachable {

  public typealias CacheType = String

  public static func decode(data: NSData) -> CacheType? {
    guard let string = String(data: data, encoding: NSUTF8StringEncoding) else {
      return nil
    }

    return string
  }

  public func encode() -> NSData? {
    return dataUsingEncoding(NSUTF8StringEncoding)
  }
}

// MARK: - Helpers

extension String {

  func base64() -> String {
    guard let data = self.dataUsingEncoding(NSUTF8StringEncoding) else { return self }
    return data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
  }
}
