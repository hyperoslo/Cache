import Foundation

protocol StorageChangeNotifier {
  func notifyObservers(about change: StorageChange)
}

struct KeyChangeNotifier<T> {
  

  func notifyObserver(about change: KeyChange<T>, where closure: ((String) -> Bool)) {
    
  }
}


/// Use both memory and disk storage. Try on memory first.
public final class HybridStorage<T> {
  public let memoryStorage: MemoryStorage<T>
  public let diskStorage: DiskStorage<T>
  let storageObservationRegistry = ObservationRegistry<StorageChange>()
  let keyObservationRegistry = ObservationRegistry<KeyChange<T>>()

  var onKeyChange: ((KeyChange<T>, ((String) -> Bool)) -> Void)?

  public init(memoryStorage: MemoryStorage<T>, diskStorage: DiskStorage<T>) {
    self.memoryStorage = memoryStorage
    self.diskStorage = diskStorage

    diskStorage.onRemove = { [weak self] path in
      self?.handleRemovedObject(at: path)
    }
  }

  private func handleRemovedObject(at path: String) {
    keyObservationRegistry.notifyObserver(about: .remove) { key in
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

    storageObservationRegistry.notifyAllObservers(about: .remove(key: key))
  }

  public func setObject(_ object: T, forKey key: String, expiry: Expiry? = nil) throws {
    var keyChange: KeyChange<T>?

    if !keyObservationRegistry.isEmpty {
      keyChange = .edit(before: try? self.object(forKey: key), after: object)
    }

    memoryStorage.setObject(object, forKey: key, expiry: expiry)
    try diskStorage.setObject(object, forKey: key, expiry: expiry)


    if let change = keyChange {
      keyObservationRegistry.notifyObserver(forKey: key, about: change)
    }

    storageObservationRegistry.notifyAllObservers(about: .add(key: key))
  }

  public func removeAll() throws {
    memoryStorage.removeAll()
    try diskStorage.removeAll()

    storageObservationRegistry.notifyAllObservers(about: .removeAll)
    keyObservationRegistry.notifyAllObservers(about: .remove)
  }

  public func removeExpiredObjects() throws {
    memoryStorage.removeExpiredObjects()
    try diskStorage.removeExpiredObjects()

    storageObservationRegistry.notifyAllObservers(about: .removeExpired)
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
