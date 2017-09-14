import Foundation

/// Manipulate storage in a "all sync" manner.
/// Block the current queue until the operation completes.
final class SyncStorage {
  let internalStorage: StorageAware
  fileprivate let serialQueue = DispatchQueue(label: "Cache.SyncStorage.Queue")

  init(storage: StorageAware) {
    self.internalStorage = storage
  }
}

extension SyncStorage: StorageAware {
  public func entry<T: Codable>(forKey key: String) throws -> Entry<T> {
    var entry: Entry<T>!
    try serialQueue.sync {
      entry = try internalStorage.entry(forKey: key) as Entry<T>
    }

    return entry
  }

  public func removeObject(forKey key: String) throws {
    try serialQueue.sync {
      try self.internalStorage.removeObject(forKey: key)
    }
  }

  public func setObject<T: Codable>(_ object: T, forKey key: String,
                                    expiry: Expiry? = nil) throws {
    try serialQueue.sync {
      try internalStorage.setObject(object, forKey: key, expiry: expiry)
    }
  }

  public func removeAll() throws {
    try serialQueue.sync {
      try internalStorage.removeAll()
    }
  }

  public func removeExpiredObjects() throws {
    try serialQueue.sync {
      try internalStorage.removeExpiredObjects()
    }
  }
}
