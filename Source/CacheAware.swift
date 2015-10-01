import Foundation

public protocol Cachable: AnyObject {}

public extension Cachable {
  func encode() -> NSData {
    var value = self
    return withUnsafePointer(&value) { p in
      NSData(bytes: p, length: sizeofValue(value))
    }
  }

  static func decode<T: Cachable>(data: NSData) -> T {
    let pointer = UnsafeMutablePointer<T>.alloc(sizeof(T.Type))
    data.getBytes(pointer, length: sizeof(T))
    return pointer.move()
  }
}

public protocol CacheAware {
  var prefix: String { get }
  var path: String { get }
  var maxSize: UInt { get set }

  init(name: String)

  func add<T: Cachable>(key: String, object: T)
  func object<T: Cachable>(key: String) -> T?
  func remove(key: String)
  func clear()
}
