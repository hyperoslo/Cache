import Foundation

public protocol KeyObservationRegistry {
  associatedtype S: StorageAware

  @discardableResult
  func addObserver<O: AnyObject>(
    _ observer: O,
    forKey key: String,
    closure: @escaping (O, S, KeyChange<S.T>) -> Void
  ) -> ObservationToken

  func removeObservation(forKey key: String)
  func removeAllKeyObservations()
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
