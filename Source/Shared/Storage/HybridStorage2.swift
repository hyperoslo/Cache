import Foundation

/// Use both memory and disk storage. Try on memory first.
class HybridStorage2<T> {
  let memoryStorage: MemoryStorage2<T>
  let diskStorage: DiskStorage2<T>

  init(memoryStorage: MemoryStorage2<T>, diskStorage: DiskStorage2<T>) {
    self.memoryStorage = memoryStorage
    self.diskStorage = diskStorage
  }
}

extension HybridStorage2: StorageAware2 {
  func entry(forKey key: String) throws -> Entry2<T> {
    do {
      return try memoryStorage.entry(forKey: key)
    } catch {
      let entry = try diskStorage.entry(forKey: key)
      // set back to memoryStorage
      memoryStorage.setObject(entry.object, forKey: key, expiry: entry.expiry)
      return entry
    }
  }

  func removeObject(forKey key: String) throws {
    memoryStorage.removeObject(forKey: key)
    try diskStorage.removeObject(forKey: key)
  }

  func setObject(_ object: T, forKey key: String, expiry: Expiry? = nil) throws {
    memoryStorage.setObject(object, forKey: key, expiry: expiry)
    try diskStorage.setObject(object, forKey: key, expiry: expiry)
  }

  func removeAll() throws {
    memoryStorage.removeAll()
    try diskStorage.removeAll()
  }

  func removeExpiredObjects() throws {
    memoryStorage.removeExpiredObjects()
    try diskStorage.removeExpiredObjects()
  }
}
