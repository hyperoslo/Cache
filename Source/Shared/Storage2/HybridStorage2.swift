import Foundation

class HybridStorage2 {
  let memoryStorage: MemoryStorage2
  let diskStorage: DiskStorage2

  init(memoryStorage: MemoryStorage2, diskStorage: DiskStorage2) {
    self.memoryStorage = memoryStorage
    self.diskStorage = diskStorage
  }
}

extension HybridStorage2: StorageAware2 {
  func entry<T: Codable>(forKey key: String) throws -> Entry2<T> {
    do {
      return try memoryStorage.entry(forKey: key)
    } catch {
      return try diskStorage.entry(forKey: key)
    }
  }

  func removeObject(forKey key: String) throws {
    memoryStorage.removeObject(forKey: key)
    try diskStorage.removeObject(forKey: key)
  }

  func setObject<T: Codable>(_ object: T, forKey key: String) throws {
    memoryStorage.setObject(object, forKey: key)
    try diskStorage.setObject(object, forKey: key)
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
