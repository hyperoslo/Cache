import Foundation
import Dispatch

/// Manipulate storage in a "all sync" manner.
/// Block the current queue until the operation completes.
public class SyncStorage2<T> {
  fileprivate let innerStorage: HybridStorage2<T>
  fileprivate let serialQueue: DispatchQueue

  init(innerStorage: HybridStorage2<T>, serialQueue: DispatchQueue) {
    self.innerStorage = innerStorage
    self.serialQueue = serialQueue
  }
}

extension SyncStorage2: StorageAware2 {
  public func entry(forKey key: String) throws -> Entry2<T> {
    var entry: Entry2<T>!
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

public extension SyncStorage2 {
  func support<U>(transformer: Transformer<U>) -> SyncStorage2<U> {
    let storage = SyncStorage2<U>(
      innerStorage: innerStorage.support(transformer: transformer),
      serialQueue: serialQueue
    )

    return storage
  }
}
