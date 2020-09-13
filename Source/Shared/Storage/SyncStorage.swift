import Foundation
import Dispatch

/// Manipulate storage in a "all sync" manner.
/// Block the current queue until the operation completes.
public class SyncStorage<Key: Hashable, Value> {
  public let innerStorage: HybridStorage<Key, Value>
  public let serialQueue: DispatchQueue

  public init(storage: HybridStorage<Key, Value>, serialQueue: DispatchQueue) {
    self.innerStorage = storage
    self.serialQueue = serialQueue
  }
}

extension SyncStorage: StorageAware {
  public func entry(forKey key: Key) throws -> Entry<Value> {
    var entry: Entry<Value>!
    try serialQueue.sync {
      entry = try innerStorage.entry(forKey: key)
    }

    return entry
  }

  public func removeObject(forKey key: Key) throws {
    try serialQueue.sync {
      try self.innerStorage.removeObject(forKey: key)
    }
  }

  public func setObject(_ object: Value, forKey key: Key, expiry: Expiry? = nil) throws {
    try serialQueue.sync {
      try innerStorage.setObject(object, forKey: key, expiry: expiry)
    }
  }

  public func removeAll() throws {
    try serialQueue.sync {
      try innerStorage.removeAll()
    }
  }

  public func removeExpiredObjects() throws {
    try serialQueue.sync {
      try innerStorage.removeExpiredObjects()
    }
  }
}

public extension SyncStorage {
  func transform<U>(transformer: Transformer<U>) -> SyncStorage<Key, U> {
    let storage = SyncStorage<Key, U>(
      storage: innerStorage.transform(transformer: transformer),
      serialQueue: serialQueue
    )

    return storage
  }
}
