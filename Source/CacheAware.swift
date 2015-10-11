import Foundation

public protocol CacheAware {
  var prefix: String { get }
  var path: String { get }
  var maxSize: UInt { get set }

  init(name: String)

  func add<T: Cachable>(key: String, object: T, completion: (() -> Void)?) -> CacheTask?
  func object<T: Cachable>(key: String, completion: (object: T?) -> Void) -> CacheTask?
  func remove(key: String, completion: (() -> Void)?) -> CacheTask?
  func clear(completion: (() -> Void)?) -> CacheTask?
}
