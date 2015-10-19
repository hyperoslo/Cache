import Foundation

public protocol Cachable {}

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
