import Foundation

/// Use both memory and disk storage. Try on memory first.
public class HybridStorage2<T> {
  let memoryStorage: MemoryStorage2<T>
  let diskStorage: DiskStorage2<T>

  init(memoryStorage: MemoryStorage2<T>, diskStorage: DiskStorage2<T>) {
    self.memoryStorage = memoryStorage
    self.diskStorage = diskStorage
  }
}

extension HybridStorage2: StorageAware2 {
  public func entry(forKey key: String) throws -> Entry2<T> {
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

public extension HybridStorage2 {
  func support<U>(transformer: Transformer<U>) -> HybridStorage2<U> {
    let storage = HybridStorage2<U>(
      memoryStorage: memoryStorage.support(),
      diskStorage: diskStorage.support(transformer: transformer)
    )

    return storage
  }
}
