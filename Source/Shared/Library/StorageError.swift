import Foundation

public enum StorageError: Error {
  /// Object can not be found
  case notFound
  /// Object is found, but casting to requested type failed
  case typeNotMatch
  /// The file attributes are malformed
  case malformedFileAttributes
  /// Can't perform Decode
  case decodingFailed
  /// Can't perform Encode
  case encodingFailed
  /// The storage has been deallocated
  case deallocated
  /// Fail to perform transformation to or from Data
  case transformerFail
}
