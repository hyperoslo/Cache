public protocol CacheAware {
  var prefix: String { get }
  var path: String { get }
  var maxSize: UInt { get set }

  init(name: String)

  func add<T: Cachable>(key: String, object: T, completion: (() -> Void)?)
  func object<T: Cachable>(key: String) -> T?
  func remove(key: String)
  func clear()
}
