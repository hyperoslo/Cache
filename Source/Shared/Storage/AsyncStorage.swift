import Foundation

/// Manipulate storage in a "all async" manner.
/// The completion closure will be called when operation completes.
final class AsyncStorage {
  let internalStorage: StorageAware
  let serialQueue = DispatchQueue(label: "Cache.AsyncStorage.Queue")

  init(storage: StorageAware) {
    self.internalStorage = storage
  }
}

extension AsyncStorage: AsyncStorageAware {
  func entry<T>(forKey key: String, completion: @escaping (Result<Entry<T>>) -> Void) {
    serialQueue.async { [weak self] in
      guard let `self` = self else {
        completion(Result.error(StorageError.deallocated))
        return
      }

      do {
        let anEntry = try self.internalStorage.entry(forKey: key) as Entry<T>
        completion(Result.value(anEntry))
      } catch {
        completion(Result.error(error))
      }
    }
  }

  func removeObject(forKey key: String, completion: @escaping (Result<()>) -> Void) {
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

  func setObject<T: Codable>(_ object: T,
                             forKey key: String,
                             expiry: Expiry?,
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

  func removeAll(completion: @escaping (Result<()>) -> Void) {
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

  func removeExpiredObjects(completion: @escaping (Result<()>) -> Void) {
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
