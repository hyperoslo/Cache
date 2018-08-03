import Foundation

/// Use both memory and disk storage. Try on memory first.
public final class HybridStorage<T>: StoreObservable {
  public let memoryStorage: MemoryStorage<T>
  public let diskStorage: DiskStorage<T>

  var observations = [UUID : (HybridStorage<T>, StoreChange) -> Void]()

  public init(memoryStorage: MemoryStorage<T>, diskStorage: DiskStorage<T>) {
    self.memoryStorage = memoryStorage
    self.diskStorage = diskStorage
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
    notifyObservers(of: .singleDeletion)
  }

  public func setObject(_ object: T, forKey key: String, expiry: Expiry? = nil) throws {
    memoryStorage.setObject(object, forKey: key, expiry: expiry)
    try diskStorage.setObject(object, forKey: key, expiry: expiry)
    notifyObservers(of: .addition)
  }

  public func removeAll() throws {
    memoryStorage.removeAll()
    try diskStorage.removeAll()
    notifyObservers(of: .allDeletion)
  }

  public func removeExpiredObjects() throws {
    memoryStorage.removeExpiredObjects()
    try diskStorage.removeExpiredObjects()
    notifyObservers(of: .expiredDeletion)
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
