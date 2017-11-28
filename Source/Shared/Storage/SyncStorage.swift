import Foundation
import Dispatch

/// Manipulate storage in a "all sync" manner.
/// Block the current queue until the operation completes.
public class SyncStorage {
  fileprivate let internalStorage: StorageAware
  fileprivate let serialQueue: DispatchQueue

  init(storage: StorageAware, serialQueue: DispatchQueue) {
    self.internalStorage = storage
    self.serialQueue = serialQueue
  }
}

extension SyncStorage: StorageAware {
  public func entry<T: Codable>(ofType type: T.Type, forKey key: String) throws -> Entry<T> {
    var entry: Entry<T>!
    try serialQueue.sync {
      entry = try internalStorage.entry(ofType: type, forKey: key)
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
