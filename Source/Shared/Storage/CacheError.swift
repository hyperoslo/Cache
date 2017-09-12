import Foundation

public enum CacheError: Error {
  /// Object can be found
  case notFound
  /// Object is found, but casting to requested type failed
  case typeNotMatch
  /// The file attributes are malformed
  case malformedFileAttributes
  /// Can't construct Codable object
  case constructCodableObjectFailed
}
