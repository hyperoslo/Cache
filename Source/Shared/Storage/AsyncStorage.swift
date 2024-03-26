import Foundation
import Dispatch

/// Manipulate storage in a "all async" manner.
/// The completion closure will be called when operation completes.
public class AsyncStorage<Key: Hashable, Value> {
  public let innerStorage: HybridStorage<Key, Value>
  public let serialQueue: DispatchQueue

  public init(storage: HybridStorage<Key, Value>, serialQueue: DispatchQueue) {
    self.innerStorage = storage
    self.serialQueue = serialQueue
  }
}

extension AsyncStorage {
  public func entry(forKey key: Key, completion: @escaping (Result<Entry<Value>, Error>) -> Void) {
    serialQueue.async { [weak self] in
      guard let `self` = self else {
        completion(.failure(StorageError.deallocated))
        return
      }

      do {
        let anEntry = try self.innerStorage.entry(forKey: key)
        completion(.success(anEntry))
      } catch {
        completion(.failure(error))
      }
    }
  }

  public func removeObject(forKey key: Key, completion: @escaping (Result<(), Error>) -> Void) {
    serialQueue.async { [weak self] in
      guard let `self` = self else {
        completion(.failure(StorageError.deallocated))
        return
      }

      do {
        try self.innerStorage.removeObject(forKey: key)
        completion(.success(()))
      } catch {
        completion(.failure(error))
      }
    }
  }

  public func setObject(
    _ object: Value,
    forKey key: Key,
    expiry: Expiry? = nil,
    completion: @escaping (Result<(), Error>) -> Void) {
    serialQueue.async { [weak self] in
      guard let `self` = self else {
        completion(.failure(StorageError.deallocated))
        return
      }

      do {
        try self.innerStorage.setObject(object, forKey: key, expiry: expiry)
        completion(.success(()))
      } catch {
        completion(.failure(error))
      }
    }
  }

  public func removeAll(completion: @escaping (Result<(), Error>) -> Void) {
    serialQueue.async { [weak self] in
      guard let `self` = self else {
        completion(.failure(StorageError.deallocated))
        return
      }

      do {
        try self.innerStorage.removeAll()
        completion(.success(()))
      } catch {
        completion(.failure(error))
      }
    }
  }

  public func removeExpiredObjects(completion: @escaping (Result<(), Error>) -> Void) {
    serialQueue.async { [weak self] in
      guard let `self` = self else {
        completion(.failure(StorageError.deallocated))
        return
      }

      do {
        try self.innerStorage.removeExpiredObjects()
        completion(.success(()))
      } catch {
        completion(.failure(error))
      }
    }
  }

  public func object(forKey key: Key, completion: @escaping (Result<Value, Error>) -> Void) {
    entry(forKey: key, completion: { (result: Result<Entry<Value>, Error>) in
      completion(result.map({ entry in
        return entry.object
      }))
    })
  }

  @available(*, deprecated, renamed: "objectExists(forKey:completion:)")
  public func existsObject(
    forKey key: Key,
    completion: @escaping (Result<Bool, Error>) -> Void) {
    object(forKey: key, completion: { (result: Result<Value, Error>) in
      completion(result.map({ _ in
        return true
      }))
    })
  }

  public func objectExists(
    forKey key: Key,
    completion: @escaping (Result<Bool, Error>) -> Void) {
      object(forKey: key, completion: { (result: Result<Value, Error>) in
        completion(result.map({ _ in
          return true
        }))
      })
    }
}

public extension AsyncStorage {
  func transform<U>(transformer: Transformer<U>) -> AsyncStorage<Key, U> {
    let storage = AsyncStorage<Key, U>(
      storage: innerStorage.transform(transformer: transformer),
      serialQueue: serialQueue
    )

    return storage
  }
}

public extension AsyncStorage {
  func applyExpiratonMode(_ expirationMode: ExpirationMode) {
    self.innerStorage.applyExpiratonMode(expirationMode)
  }
}
