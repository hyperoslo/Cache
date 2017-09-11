import Foundation

public enum CacheError2: Error {
  /// Object can be found
  case notFound
  /// Object is found, but casting to requested type failed
  case typeNotMatch
  /// The file attributes are malformed
  case malformedFileAttributes
}
