import Foundation

public final class StorageObservationRegistry<Storage: StorageAware> {
  public typealias Observation = (Storage, StorageChange) -> Void
  private(set) var observations = [UUID: Observation]()

  public var isEmpty: Bool {
    return observations.isEmpty
  }

  @discardableResult
  public func addObservation(_ observation: @escaping Observation) -> ObservationToken {
    let id = UUID()
    observations[id] = observation

    return ObservationToken { [weak self] in
      self?.observations.removeValue(forKey: id)
    }
  }

  public func removeObservation(token: ObservationToken) {
    token.cancel()
  }

  public func removeAllObservations() {
    observations.removeAll()
  }

  func notifyObservers(about change: StorageChange, in storage: Storage) {
    observations.values.forEach { closure in
      closure(storage, change)
    }
  }
}

// MARK: - StorageChange

public enum StorageChange: Equatable {
  case add(key: String)
  case remove(key: String)
  case removeAll
  case removeExpired
}

public func == (lhs: StorageChange, rhs: StorageChange) -> Bool {
  switch (lhs, rhs) {
  case (.add(let key1), .add(let key2)), (.remove(let key1), .remove(let key2)):
    return key1 == key2
  case (.removeAll, .removeAll), (.removeExpired, .removeExpired):
    return true
  default:
    return false
  }
}
