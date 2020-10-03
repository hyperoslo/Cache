import Foundation

/// A protocol used for adding and removing key observations
public protocol KeyObservationRegistry {
  associatedtype S: StorageAware

  /**
   Registers observation closure which will be removed automatically
   when the weakly captured observer has been deallocated.
   - Parameter observer: Any object that helps determine if the observation is still valid
   - Parameter key: Unique key to identify the object in the cache
   - Parameter closure: Observation closure
   - Returns: Token used to cancel the observation and remove the observation closure
   */
  @discardableResult
  func addObserver<O: AnyObject>(
    _ observer: O,
    forKey key: S.Key,
    closure: @escaping (O, S, KeyChange<S.Value>) -> Void
  ) -> ObservationToken

  /**
   Removes observer by the given key.
   - Parameter key: Unique key to identify the object in the cache
   */
  func removeObserver(forKey key: S.Key)

  /// Removes all registered key observers
  func removeAllKeyObservers()
}

// MARK: - KeyChange

public enum KeyChange<T> {
  case edit(before: T?, after: T)
  case remove
}

extension KeyChange: Equatable where T: Equatable {
  public static func == (lhs: KeyChange<T>, rhs: KeyChange<T>) -> Bool {
    switch (lhs, rhs) {
    case (.edit(let before1, let after1), .edit(let before2, let after2)):
      return before1 == before2 && after1 == after2
    case (.remove, .remove):
      return true
    default:
      return false
    }
  }
}
