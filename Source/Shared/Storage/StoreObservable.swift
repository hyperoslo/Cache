import Foundation

protocol StoreObservable: class {
  var observations: [UUID : (Self, StoreChange) -> Void] { get set }
}

extension StoreObservable {
  @discardableResult
  public func observeChanges(using closure: @escaping (Self, StoreChange) -> Void) -> ObservationToken {
    let id = UUID()
    observations[id] = closure

    return ObservationToken { [weak self] in
      self?.observations.removeValue(forKey: id)
    }
  }

  func notifyObservers(of change: StoreChange) {
    observations.values.forEach { [weak self] closure in
      guard let strongSelf = self else {
        return
      }
      closure(strongSelf, change)
    }
  }
}
