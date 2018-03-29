import Foundation

/// Use both memory and disk storage. Try on memory first.
class HybridStorage {
  let memoryStorage: MemoryStorage
  let diskStorage: DiskStorage

  init(memoryStorage: MemoryStorage, diskStorage: DiskStorage) {
    self.memoryStorage = memoryStorage
    self.diskStorage = diskStorage
  }
}

extension HybridStorage: StorageAware {
  func entry<T: Codable>(ofType type: T.Type, forKey key: String) throws -> Entry<T> {
    do {
      return try memoryStorage.entry(ofType: type, forKey: key)
    } catch {
      let entry = try diskStorage.entry(ofType: type, forKey: key)
      // set back to memoryStorage
      memoryStorage.setObject(entry.object, forKey: key, expiry: entry.expiry)
      return entry
    }
  }

  func removeObject(forKey key: String) throws {
    memoryStorage.removeObject(forKey: key)
    try diskStorage.removeObject(forKey: key)
  }

  func setObject<T: Codable>(_ object: T, forKey key: String, expiry: Expiry? = nil) throws {
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
