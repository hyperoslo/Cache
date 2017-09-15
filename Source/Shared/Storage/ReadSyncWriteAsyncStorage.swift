import Foundation

/// Manipulate storage in a "read sync, write async" manner.
public class ReadSyncWriteAsyncStorage {
  let internalStorage: StorageAware
  let concurrentQueue = DispatchQueue(label: "Cache.ReadSyncWriteAsyncStorage.Queue",
                                      attributes: .concurrent)

  init(storage: StorageAware) {
    self.internalStorage = storage
  }
}

extension ReadSyncWriteAsyncStorage {
  public func entry<T: Codable>(forKey key: String) throws -> Entry<T> {
    var entry: Entry<T>!
    try concurrentQueue.sync {
      entry = try internalStorage.entry(forKey: key) as Entry<T>
    }

    return entry
  }

  public func object<T: Codable>(forKey key: String) throws -> T {
    return try entry(forKey: key).object
  }

  public func existsObject<T: Codable>(ofType type: T.Type, forKey key: String) throws -> Bool {
    do {
      let _: T = try object(forKey: key)
      return true
    } catch {
      return false
    }
  }

  public func removeObject(forKey key: String, completion: @escaping (Result<()>) -> Void) {
    concurrentQueue.async(flags: .barrier) { [weak self] in
      guard let `self` = self else {
        completion(Result.error(StorageError.deallocated))
        return
      }

      do {
        try self.internalStorage.removeObject(forKey: key)
        completion(Result.value(()))
      } catch {
        completion(Result.error(error))
      }
    }
  }

  public func setObject<T: Codable>(_ object: T,
                             forKey key: String,
                             expiry: Expiry? = nil,
                             completion: @escaping (Result<()>) -> Void) {
    concurrentQueue.async(flags: .barrier) { [weak self] in
      guard let `self` = self else {
        completion(Result.error(StorageError.deallocated))
        return
      }

      do {
        try self.internalStorage.setObject(object, forKey: key, expiry: expiry)
        completion(Result.value(()))
      } catch {
        completion(Result.error(error))
      }
    }
  }

  public func removeAll(completion: @escaping (Result<()>) -> Void) {
    concurrentQueue.async(flags: .barrier) { [weak self] in
      guard let `self` = self else {
        completion(Result.error(StorageError.deallocated))
        return
      }

      do {
        try self.internalStorage.removeAll()
        completion(Result.value(()))
      } catch {
        completion(Result.error(error))
      }
    }
  }

  public func removeExpiredObjects(completion: @escaping (Result<()>) -> Void) {
    concurrentQueue.async(flags: .barrier) { [weak self] in
      guard let `self` = self else {
        completion(Result.error(StorageError.deallocated))
        return
      }

      do {
        try self.internalStorage.removeExpiredObjects()
        completion(Result.value(()))
      } catch {
        completion(Result.error(error))
      }
    }
  }
}
