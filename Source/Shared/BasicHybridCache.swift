import Foundation

/**
 BasicHybridCache supports storing all kinds of objects, as long as they conform to
 Cachable protocol. It's two layered cache (with front and back storages)
 */
public class BasicHybridCache: NSObject {

  /// A name of the cache
  public let name: String

  /// Cache configuration
  let config: Config
  /// Front cache (should be less time and memory consuming)
  let frontStorage: StorageAware
  // BAck cache (used for content that outlives the application life-cycle)
  var backStorage: StorageAware

  public var path: String {
    return backStorage.path
  }

  // MARK: - Inititalization

  /**
   Creates a new instance of BasicHybridCache.

   - Parameter name: A name of the cache
   - Parameter config: Cache configuration
   */
  public init(name: String, config: Config = Config.defaultConfig) {
    self.name = name
    self.config = config

    frontStorage = StorageFactory.resolve(name, kind: config.frontKind, maxSize: UInt(config.maxObjects))
    backStorage = StorageFactory.resolve(name, kind: config.backKind, maxSize: config.maxSize)

    super.init()
  }

  // MARK: - Caching

  /**
   Adds passed object to the front and back cache storages.

   - Parameter key: Unique key to identify the object in the cache
   - Parameter object: Object that needs to be cached
   - Parameter expiry: Expiration date for the cached object
   - Parameter completion: Completion closure to be called when the task is done
   */
  public func add<T: Cachable>(_ key: String, object: T, expiry: Expiry? = nil, completion: (() -> Void)? = nil) {
    let expiry = expiry ?? config.expiry

    frontStorage.add(key, object: object, expiry: expiry) { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      weakSelf.backStorage.add(key, object: object, expiry: expiry) {
        completion?()
      }
    }
  }

  /**
   Tries to retrieve the object from to the front and back cache storages.

   - Parameter key: Unique key to identify the object in the cache
   - Parameter completion: Completion closure returns object or nil
   */
  public func object<T: Cachable>(_ key: String, completion: @escaping (_ object: T?) -> Void) {
    frontStorage.object(key) { [weak self] (object: T?) in
      if let object = object {
        completion(object)
        return
      }

      guard let weakSelf = self else {
        completion(object)
        return
      }

      weakSelf.backStorage.object(key) { (object: T?) in
        completion(object)
      }
    }
  }

  /**
   Removes the object from to the front and back cache storages.

   - Parameter key: Unique key to identify the object in the cache
   - Parameter completion: Completion closure to be called when the task is done
   */
  public func remove(_ key: String, completion: (() -> Void)? = nil) {
    frontStorage.remove(key) { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      weakSelf.backStorage.remove(key) {
        completion?()
      }
    }
  }

  /**
   Clears the front and back cache storages.

   - Parameter completion: Completion closure to be called when the task is done
   */
  public func clear(_ completion: (() -> Void)? = nil) {
    frontStorage.clear() { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      weakSelf.backStorage.clear() {
        completion?()
      }
    }
  }

  /**
   Clears all expired objects from front and back storages.
     
   - Parameter completion: Completion closure to be called when the task is done
   */
  public func clearExpired(_ completion: (() -> Void)? = nil) {
    frontStorage.clearExpired { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }
            
      weakSelf.backStorage.clearExpired() {
        completion?()
      }
    }
  }
}
