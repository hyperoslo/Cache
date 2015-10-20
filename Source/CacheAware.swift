import Foundation

public protocol CacheAware {
  var prefix: String { get }
  var path: String { get }
  var maxSize: UInt { get set }

  init(name: String)

  func add<T: Cachable>(key: String, object: T, start: Bool, completion: (() -> Void)?) -> CacheTask?
  func object<T: Cachable>(key: String, start: Bool,  completion: (object: T?) -> Void) -> CacheTask?
  func remove(key: String, start: Bool, completion: (() -> Void)?) -> CacheTask?
  func clear(start: Bool, completion: (() -> Void)?) -> CacheTask?
}
