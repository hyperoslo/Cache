import Foundation

/// A protocol used for saving and loading from storage
public protocol StorageAware {
  associatedtype Key: Hashable
  associatedtype Value

  /**
   Get all keys in the storage
  */
  var allKeys: [Key] { get }

  /**
   Get all objects from the storage
  */
  var allObjects: [Value] { get }
  
  /**
   Tries to retrieve the object from the storage.
   - Parameter key: Unique key to identify the object in the cache
   - Returns: Cached object or nil if not found
   */
  func object(forKey key: Key) throws -> Value

  /**
   Get cache entry which includes object with metadata.
   - Parameter key: Unique key to identify the object in the cache
   - Returns: Object wrapper with metadata or nil if not found
   */
  func entry(forKey key: Key) throws -> Entry<Value>

  /**
   Removes the object by the given key.
   - Parameter key: Unique key to identify the object.
   */
  func removeObject(forKey key: Key) throws

  /**
   Saves passed object.
   - Parameter key: Unique key to identify the object in the cache.
   - Parameter object: Object that needs to be cached.
   - Parameter expiry: Overwrite expiry for this object only.
   */
  func setObject(_ object: Value, forKey key: Key, expiry: Expiry?) throws

  /**
   Check if an object exist by the given key.
   - Parameter key: Unique key to identify the object.
   */
  @available(*, deprecated, renamed: "objectExists(forKey:)")
  func existsObject(forKey key: Key) throws -> Bool

  /**
   Check if an object exist by the given key.
   - Parameter key: Unique key to identify the object.
   */
  func objectExists(forKey key: Key) -> Bool

  /**
   Removes all objects from the cache storage.
   */
  func removeAll() throws

  /**
   Clears all expired objects.
   */
  func removeExpiredObjects() throws

  /**
   Check if an expired object by the given key.
   - Parameter key: Unique key to identify the object.
   */
  func isExpiredObject(forKey key: Key) throws -> Bool
  /**
   Removes the object by the given key from cache in memory only.
   - Parameter key: Unique key to identify the object.
   */
  func removeInMemoryObject(forKey key: Key) throws
}

public extension StorageAware {
  func object(forKey key: Key) throws -> Value {
    return try entry(forKey: key).object
  }

  func existsObject(forKey key: Key) throws -> Bool {
    do {
      let _: Value = try object(forKey: key)
      return true
    } catch {
      return false
    }
  }

  func objectExists(forKey key: Key) -> Bool {
    do {
      let _: Value = try object(forKey: key)
      return true
    } catch {
      return false
    }
  }

  func isExpiredObject(forKey key: Key) throws -> Bool {
    do {
      let entry = try self.entry(forKey: key)
      return entry.expiry.isExpired
    } catch {
      return true
    }
  }
}
