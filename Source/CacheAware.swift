public protocol CacheAware {
  var prefix: String { get }
  var path: String { get }
  var maxSize: UInt { get set }

  init(name: String)

  func add<T: AnyObject>(key: String, object: T)
  func object<T: AnyObject>(key: String) -> T?
  func remove(key: String)
  func clear()
}
