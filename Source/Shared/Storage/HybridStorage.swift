import Foundation

/// Use both memory and disk storage. Try on memory first.
public final class HybridStorage<T> {
  public let memoryStorage: MemoryStorage<T>
  public let diskStorage: DiskStorage<T>

  private var observations = (
    storage: [UUID : (HybridStorage, StorageChange) -> Void](),
    key: [String : (HybridStorage, KeyChange<T>) -> Void]()
  )

  public init(memoryStorage: MemoryStorage<T>, diskStorage: DiskStorage<T>) {
    self.memoryStorage = memoryStorage
    self.diskStorage = diskStorage

    diskStorage.onRemove = { [weak self] path in
      self?.handleRemovedObject(at: path)
    }
  }

  private func handleRemovedObject(at path: String) {
    notifyObserver(about: .remove) { key in
      let fileName = diskStorage.makeFileName(for: key)
      return path.contains(fileName)
    }
  }
}

extension HybridStorage: StorageAware {
  public func entry(forKey key: String) throws -> Entry<T> {
    do {
      return try memoryStorage.entry(forKey: key)
    } catch {
      let entry = try diskStorage.entry(forKey: key)
      // set back to memoryStorage
      memoryStorage.setObject(entry.object, forKey: key, expiry: entry.expiry)
      return entry
    }
  }

  public func removeObject(forKey key: String) throws {
    memoryStorage.removeObject(forKey: key)
    try diskStorage.removeObject(forKey: key)

    notifyStorageObservers(about: .remove(key: key))
  }

  public func setObject(_ object: T, forKey key: String, expiry: Expiry? = nil) throws {
    var keyChange: KeyChange<T>?

    if observations.key[key] != nil {
      keyChange = .edit(before: try? self.object(forKey: key), after: object)
    }

    memoryStorage.setObject(object, forKey: key, expiry: expiry)
    try diskStorage.setObject(object, forKey: key, expiry: expiry)


    if let change = keyChange {
      notifyObserver(forKey: key, about: change)
    }

    notifyStorageObservers(about: .add(key: key))
  }

  public func removeAll() throws {
    memoryStorage.removeAll()
    try diskStorage.removeAll()

    notifyStorageObservers(about: .removeAll)
    notifyKeyObservers(about: .remove)
  }

  public func removeExpiredObjects() throws {
    memoryStorage.removeExpiredObjects()
    try diskStorage.removeExpiredObjects()

    notifyStorageObservers(about: .removeExpired)
  }
}

public extension HybridStorage {
  func transform<U>(transformer: Transformer<U>) -> HybridStorage<U> {
    let storage = HybridStorage<U>(
      memoryStorage: memoryStorage.transform(),
      diskStorage: diskStorage.transform(transformer: transformer)
    )

    return storage
  }
}

extension HybridStorage: StorageObservationRegistry {
  @discardableResult
  public func observeStorage(using closure: @escaping (HybridStorage, StorageChange) -> Void) -> ObservationToken {
    let id = UUID()
    observations.storage[id] = closure

    return ObservationToken { [weak self] in
      self?.observations.storage.removeValue(forKey: id)
    }
  }
  
  public func removeAllStorageObservations() {
    observations.storage.removeAll()
  }

  private func notifyStorageObservers(about change: StorageChange) {
    observations.storage.values.forEach { closure in
      closure(self, change)
    }
  }
}

extension HybridStorage: KeyObservationRegistry {
  @discardableResult
  public func observeKey(_ key: String, using closure: @escaping (HybridStorage, KeyChange<T>) -> Void) -> ObservationToken {
    observations.key[key] = closure

    return ObservationToken { [weak self] in
      self?.observations.key.removeValue(forKey: key)
    }
  }

  public func removeObservation(forKey key: String) {
    observations.key.removeValue(forKey: key)
  }

  public func removeAllKeyObservations() {
    observations.key.removeAll()
  }

  private func notifyObserver(forKey key: String, about change: KeyChange<T>) {
    observations.key[key]?(self, change)
  }

  private func notifyObserver(about change: KeyChange<T>, whereKey closure: ((String) -> Bool)) {
    let observation = observations.key.first { key, value in closure(key) }?.value
    observation?(self, change)
  }

  private func notifyKeyObservers(about change: KeyChange<T>) {
    observations.key.values.forEach { closure in
      closure(self, change)
    }
  }
}
