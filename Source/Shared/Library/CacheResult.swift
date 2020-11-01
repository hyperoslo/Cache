import Foundation

/// Used for callback in async operations.
public enum CacheResult<T> {
  case value(T)
  case error(Error)

  public func map<U>(_ transform: (T) -> U) -> CacheResult<U> {
    switch self {
    case .value(let value):
      return CacheResult<U>.value(transform(value))
    case .error(let error):
      return CacheResult<U>.error(error)
    }
  }
}
