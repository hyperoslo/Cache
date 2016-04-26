import Foundation

public struct Syncer<T: Cachable> {

  let cache: Cache<T>

  public init(_ cache: Cache<T>) {
    self.cache = cache
  }

  public func add(key: String, object: T, expiry: Expiry? = nil) {
    let semaphore = dispatch_semaphore_create(0)

    cache.add(key, object: object, expiry: expiry) {
      dispatch_semaphore_signal(semaphore)
    }

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
  }

  public func object(key: String) -> T? {
    var result: T?

    let semaphore = dispatch_semaphore_create(0)

    cache.object(key) { (object: T?) in
      result = object
      dispatch_semaphore_signal(semaphore)
    }

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)

    return result
  }
}
