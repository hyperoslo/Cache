import Foundation

public final class StorageObservationRegistry<T: StorageAware> {
  public typealias Observation = (T, StorageChange) -> Void
  private(set) var observations = [UUID: Observation]()

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

  func notifyObservers(about change: StorageChange, in storage: T) {
    observations.values.forEach { closure in
      closure(storage, change)
    }
  }
}
