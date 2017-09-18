import Foundation

/// Manipulate storage in a "all async" manner.
/// The completion closure will be called when operation completes.
public class AsyncStorage {
  fileprivate let internalStorage: StorageAware
  public let serialQueue: DispatchQueue

  init(storage: StorageAware, serialQueue: DispatchQueue) {
    self.internalStorage = storage
    self.serialQueue = serialQueue
  }
}

extension AsyncStorage: AsyncStorageAware {
  public func entry<T>(ofType type: T.Type, forKey key: String, completion: @escaping (Result<Entry<T>>) -> Void) {
    serialQueue.async { [weak self] in
      guard let `self` = self else {
        completion(Result.error(StorageError.deallocated))
        return
      }

      do {
        let anEntry = try self.internalStorage.entry(ofType: type, forKey: key)
        completion(Result.value(anEntry))
      } catch {
        completion(Result.error(error))
      }
    }
  }

  public func removeObject(forKey key: String, completion: @escaping (Result<()>) -> Void) {
    serialQueue.async { [weak self] in
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
    serialQueue.async { [weak self] in
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
    serialQueue.async { [weak self] in
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
    serialQueue.async { [weak self] in
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
