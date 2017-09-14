import Foundation

/// Used for callback in async operations.
public enum Result<T> {
  case value(T)
  case error(Error)

  public func map<U>(_ transform: (T) -> U) -> Result<U> {
    switch self {
    case .value(let value):
      return Result<U>.value(transform(value))
    case .error(let error):
      return Result<U>.error(error)
    }
  }
}
