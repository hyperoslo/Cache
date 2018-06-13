import Foundation
import Dispatch

/// Manipulate storage in a "all sync" manner.
/// Block the current queue until the operation completes.
public class SyncStorage<T> {
  public let innerStorage: HybridStorage<T>
  public let serialQueue: DispatchQueue

  public init(storage: HybridStorage<T>, serialQueue: DispatchQueue) {
    self.innerStorage = storage
    self.serialQueue = serialQueue
  }
}

extension SyncStorage: StorageAware {
  public func entry(forKey key: String) throws -> Entry<T> {
    var entry: Entry<T>!
    try serialQueue.sync {
      entry = try innerStorage.entry(forKey: key)
    }

    return entry
  }

  public func removeObject(forKey key: String) throws {
    try serialQueue.sync {
      try self.innerStorage.removeObject(forKey: key)
    }
  }

  public func setObject(_ object: T, forKey key: String, expiry: Expiry? = nil) throws {
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
  func transform<U>(transformer: Transformer<U>) -> SyncStorage<U> {
    let storage = SyncStorage<U>(
      storage: innerStorage.transform(transformer: transformer),
      serialQueue: serialQueue
    )

    return storage
  }
}
