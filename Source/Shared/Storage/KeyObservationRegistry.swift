import Foundation

public final class KeyObservationRegistry<Storage: StorageAware> {
  public typealias Observation = (Storage, KeyChange<Storage.T>) -> Void
  private(set) var observations = [String: Observation]()
  var onNewKey: ((String) -> Void)?

  public var isEmpty: Bool {
    return observations.isEmpty
  }

  @discardableResult
  public func addObservation(_ observation: @escaping Observation, forKey key: String) -> ObservationToken {
    observations[key] = observation
    onNewKey?(key)

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

  func notifyObserver(forKey key: String, about change: KeyChange<Storage.T>, in storage: Storage) {
    observations[key]?(storage, change)
  }

  func notifyObserver(about change: KeyChange<Storage.T>,
                      in storage: Storage,
                      where closure: ((String) -> Bool)) {
    let observation = observations.first { key, value in closure(key) }?.value
    observation?(storage, change)
  }

  func notifyAllObservers(about change: KeyChange<Storage.T>, in storage: Storage) {
    observations.values.forEach { closure in
      closure(storage, change)
    }
  }
}

// MARK: - Notification

public struct KeyNotification<Storage: StorageAware> {
  public let change: KeyChange<Storage.T>
  public let storage: Storage
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





final class ObservationRegistry<Change> {
  typealias Observation = (Change) -> Void
  private(set) var observations = [String: Observation]()

  var isEmpty: Bool {
    return observations.isEmpty
  }

  @discardableResult
  func addObservation(forKey key: String = UUID().uuidString, _ observation: @escaping Observation) -> ObservationToken {
    observations[key] = observation
    return ObservationToken { [weak self] in
      self?.observations.removeValue(forKey: key)
    }
  }

  func removeObservation(forKey key: String) {
    observations.removeValue(forKey: key)
  }

  func removeAllObservations() {
    observations.removeAll()
  }

  func notifyObserver(forKey key: String, about change: Change) {
    observations[key]?(change)
  }

  func notifyObserver(about change: Change, where closure: ((String) -> Bool)) {
    let observation = observations.first { key, value in closure(key) }?.value
    observation?(change)
  }

  func notifyAllObservers(about change: Change) {
    observations.values.forEach { closure in
      closure(change)
    }
  }
}
