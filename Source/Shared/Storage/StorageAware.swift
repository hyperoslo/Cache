import Foundation

public protocol CacheAware {
  
  func add<T: Cachable>(key: String, object: T, expiry: Expiry, completion: (() -> Void)?)
  func object<T: Cachable>(key: String, completion: (object: T?) -> Void)
  func remove(key: String, completion: (() -> Void)?)
  func removeIfExpired(key: String, completion: (() -> Void)?)
  func clear(completion: (() -> Void)?)
  func clearExpired(completion: (() -> Void)?)
}

public protocol StorageAware: CacheAware {
  static var prefix: String { get }

  var path: String { get }
  var maxSize: UInt { get set }
  var writeQueue: dispatch_queue_t { get }
  var readQueue: dispatch_queue_t { get }

  init(name: String, maxSize: UInt)
}
