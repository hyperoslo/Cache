import Foundation

/// Use both memory and disk storage. Try on memory first.
public class HybridStorage<T> {
  let memoryStorage: MemoryStorage<T>
  let diskStorage: DiskStorage<T>

  init(memoryStorage: MemoryStorage<T>, diskStorage: DiskStorage<T>) {
    self.memoryStorage = memoryStorage
    self.diskStorage = diskStorage
  }
}

extension HybridStorage: StorageAware2 {
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
  }

  public func setObject(_ object: T, forKey key: String, expiry: Expiry? = nil) throws {
    memoryStorage.setObject(object, forKey: key, expiry: expiry)
    try diskStorage.setObject(object, forKey: key, expiry: expiry)
  }

  public func removeAll() throws {
    memoryStorage.removeAll()
    try diskStorage.removeAll()
  }

  public func removeExpiredObjects() throws {
    memoryStorage.removeExpiredObjects()
    try diskStorage.removeExpiredObjects()
  }
}

public extension HybridStorage {
  func support<U>(transformer: Transformer<U>) -> HybridStorage<U> {
    let storage = HybridStorage<U>(
      memoryStorage: memoryStorage.support(),
      diskStorage: diskStorage.support(transformer: transformer)
    )

    return storage
  }
}
