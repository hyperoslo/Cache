import Foundation

public protocol Cachable: AnyObject {}

public extension Cachable {
  
  func encode() -> NSData {
    var value = self
    return withUnsafePointer(&value) { p in
      NSData(bytes: p, length: sizeofValue(value))
    }
  }

  static func decode(data: NSData) -> Self {
    typealias CurrentSelf = Self

    let pointer = UnsafeMutablePointer<CurrentSelf>.alloc(sizeof(CurrentSelf.Type))
    data.getBytes(pointer, length: sizeof(Self))
    return pointer.move()
  }
}
