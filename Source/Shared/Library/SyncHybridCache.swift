import Foundation

public struct SyncHybridCache {

  let cache: BasicHybridCache

  // MARK: - Initialization

  public init(_ cache: BasicHybridCache) {
    self.cache = cache
  }

  // MARK: - Caching

  public func add<T: Cachable>(key: String, object: T, expiry: Expiry? = nil) {
    let semaphore = dispatch_semaphore_create(0)

    cache.add(key, object: object, expiry: expiry) {
      dispatch_semaphore_signal(semaphore)
    }

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
  }

  public func object<T: Cachable>(key: String) -> T? {
    var result: T?

    let semaphore = dispatch_semaphore_create(0)

    cache.object(key) { (object: T?) in
      result = object
      dispatch_semaphore_signal(semaphore)
    }

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)

    return result
  }

  public func remove(key: String) {
    let semaphore = dispatch_semaphore_create(0)

    cache.remove(key) {
      dispatch_semaphore_signal(semaphore)
    }

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
  }

  public func clear() {
    let semaphore = dispatch_semaphore_create(0)

    cache.clear() {
      dispatch_semaphore_signal(semaphore)
    }

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
  }
}
