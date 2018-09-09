import Foundation
import Dispatch

/// Manipulate storage in a "all sync" manner.
/// Block the current queue until the operation completes.
public class SyncStorage<T> {
  public let innerStorage: HybridStorage<T>
  public let serialQueue: DispatchQueue
  public let autoRemove: Bool

  public init(storage: HybridStorage<T>, serialQueue: DispatchQueue, autoRemove: Bool) {
    self.innerStorage = storage
    self.serialQueue = serialQueue
    self.autoRemove = autoRemove
  }
}

extension SyncStorage: AllEntriesRetriever {
  func entries() throws -> [Entry<T>] {
    var entries: [Entry<T>] = []
    try serialQueue.sync {
      entries = try innerStorage.entries()
    }

    if autoRemove {
      serialQueue.async {
        entries.filter({ $0.expiry.isExpired }).forEach({[weak self] entry in
          guard let `self` = self else { return }
          if let key = entry.key {
            do {
              try self.removeObject(forKey: key)
            } catch {}
          }
        })
      }
      return entries.filter({ !$0.expiry.isExpired })
    }
    return entries
  }
}

extension SyncStorage: StorageAware {
  public func entry(forKey key: String) throws -> Entry<T> {
    var entry: Entry<T>!
    try serialQueue.sync {
      entry = try innerStorage.entry(forKey: key)
    }

    if autoRemove && entry.expiry.isExpired {
      try serialQueue.sync {
        if let key = entry.key {
          try innerStorage.removeObject(forKey: key)
        }
      }
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
      serialQueue: serialQueue,
      autoRemove: autoRemove
    )

    return storage
  }
}
