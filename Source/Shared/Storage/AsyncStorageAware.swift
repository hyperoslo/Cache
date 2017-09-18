import Foundation

/// A protocol used for saving and loading from storage in async manner.
public protocol AsyncStorageAware: class {
  /// All async operation must act on a serial queue.
  var serialQueue: DispatchQueue { get }

  /**
   Tries to retrieve the object from the storage.
   - Parameter key: Unique key to identify the object in the cache.
   - Parameter completion: Triggered until the operation completes.
   */
  func object<T: Codable>(ofType type: T.Type, forKey key: String, completion: @escaping (Result<T>) -> Void)

  /**
   Get cache entry which includes object with metadata.
   - Parameter key: Unique key to identify the object in the cache
   - Parameter completion: Triggered until the operation completes.
   */
  func entry<T>(ofType type: T.Type, forKey key: String, completion: @escaping (Result<Entry<T>>) -> Void)

  /**
   Removes the object by the given key.
   - Parameter key: Unique key to identify the object.
   - Parameter completion: Triggered until the operation completes.
   */
  func removeObject(forKey key: String, completion: @escaping (Result<()>) -> Void)

  /**
   Saves passed object.
   - Parameter key: Unique key to identify the object in the cache.
   - Parameter object: Object that needs to be cached.
   - Parameter expiry: Overwrite expiry for this object only.
   - Parameter completion: Triggered until the operation completes.
   */
  func setObject<T: Codable>(_ object: T,
                             forKey key: String,
                             expiry: Expiry?,
                             completion: @escaping (Result<()>) -> Void)

  /**
   Check if an object exist by the given key.
   - Parameter key: Unique key to identify the object.
   - Parameter completion: Triggered until the operation completes.
   */
  func existsObject<T: Codable>(ofType type: T.Type,
                                forKey key: String,
                                completion: @escaping (Result<Bool>) -> Void)

  /**
   Removes all objects from the cache storage.
   - Parameter completion: Triggered until the operation completes.
   */
  func removeAll(completion: @escaping (Result<()>) -> Void)

  /**
   Clears all expired objects.
   - Parameter completion: Triggered until the operation completes.
   */
  func removeExpiredObjects(completion: @escaping (Result<()>) -> Void)
}

public extension AsyncStorageAware {
  func object<T: Codable>(ofType type: T.Type, forKey key: String, completion: @escaping (Result<T>) -> Void) {
    entry(ofType: type, forKey: key, completion: { (result: Result<Entry<T>>) in
      completion(result.map({ entry in
        return entry.object
      }))
    })
  }

  func existsObject<T: Codable>(ofType type: T.Type,
                                forKey key: String,
                                completion: @escaping (Result<Bool>) -> Void) {
    object(ofType: type, forKey: key, completion: { (result: Result<T>) in
      completion(result.map({ _ in
        return true
      }))
    })
  }
}
