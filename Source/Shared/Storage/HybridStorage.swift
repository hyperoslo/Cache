import Foundation

class HybridStorage {
  let memoryStorage: MemoryStorage
  let diskStorage: DiskStorage

  init(memoryStorage: MemoryStorage, diskStorage: DiskStorage) {
    self.memoryStorage = memoryStorage
    self.diskStorage = diskStorage
  }
}

extension HybridStorage: StorageAware {
  func entry<T: Codable>(forKey key: String) throws -> Entry<T> {
    do {
      return try memoryStorage.entry(forKey: key)
    } catch {
      let entry = try diskStorage.entry(forKey: key) as Entry<T>
      // set back to memoryStorage
      memoryStorage.setObject(entry.object, forKey: key)
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