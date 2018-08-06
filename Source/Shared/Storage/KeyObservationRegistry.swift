import Foundation

public enum KeyChange<T> {
  case edit(before: T?, after: T?)
  case remove
}

public final class KeyObservationRegistry<Storage: StorageAware> {
  public typealias Observation = (Storage, KeyChange<Storage.T>) -> Void
  private(set) var observations = [String: Observation]()

  @discardableResult
  public func addObservation(_ observation: @escaping Observation, forKey key: String) -> ObservationToken {
    observations[key] = observation

    return ObservationToken { [weak self] in
      self?.observations.removeValue(forKey: key)
    }
  }

  public func removeObservation(forKey key: String) {
    observations.removeValue(forKey: key)
  }

  public func removeObservation(token: ObservationToken) {
    token.cancel()
  }

  public func removeAllObservations() {
    observations.removeAll()
  }

  func notifyObservers(about change: KeyChange<Storage.T>, in storage: Storage) {
    observations.values.forEach { closure in
      closure(storage, change)
    }
  }
}
