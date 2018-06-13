import Foundation
import Dispatch

/// Manipulate storage in a "all async" manner.
/// The completion closure will be called when operation completes.
public class AsyncStorage<T> {
  public let innerStorage: HybridStorage<T>
  public let serialQueue: DispatchQueue

  public init(storage: HybridStorage<T>, serialQueue: DispatchQueue) {
    self.innerStorage = storage
    self.serialQueue = serialQueue
  }
}

extension AsyncStorage {
  public func entry(forKey key: String, completion: @escaping (Result<Entry<T>>) -> Void) {
    serialQueue.async { [weak self] in
      guard let `self` = self else {
        completion(Result.error(StorageError.deallocated))
        return
      }

      do {
        let anEntry = try self.innerStorage.entry(forKey: key)
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
        try self.innerStorage.removeObject(forKey: key)
        completion(Result.value(()))
      } catch {
        completion(Result.error(error))
      }
    }
  }

  public func setObject(
    _ object: T,
    forKey key: String,
    expiry: Expiry? = nil,
    completion: @escaping (Result<()>) -> Void) {
    serialQueue.async { [weak self] in
      guard let `self` = self else {
        completion(Result.error(StorageError.deallocated))
        return
      }

      do {
        try self.innerStorage.setObject(object, forKey: key, expiry: expiry)
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
        try self.innerStorage.removeAll()
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
        try self.innerStorage.removeExpiredObjects()
        completion(Result.value(()))
      } catch {
        completion(Result.error(error))
      }
    }
  }

  public func object(forKey key: String, completion: @escaping (Result<T>) -> Void) {
    entry(forKey: key, completion: { (result: Result<Entry<T>>) in
      completion(result.map({ entry in
        return entry.object
      }))
    })
  }

  public func existsObject(
    forKey key: String,
    completion: @escaping (Result<Bool>) -> Void) {
    object(forKey: key, completion: { (result: Result<T>) in
      completion(result.map({ _ in
        return true
      }))
    })
  }
}

public extension AsyncStorage {
  func transform<U>(transformer: Transformer<U>) -> AsyncStorage<U> {
    let storage = AsyncStorage<U>(
      storage: innerStorage.transform(transformer: transformer),
      serialQueue: serialQueue
    )

    return storage
  }
}
