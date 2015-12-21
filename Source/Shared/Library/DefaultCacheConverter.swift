import Foundation

public enum EncodingError: ErrorType {
  case InvalidSize
}

public struct DefaultCacheConverter<T> {

  public init() {}

  public func decode(data: NSData) throws -> T {
    guard data.length == sizeof(T) else {
      throw EncodingError.InvalidSize
    }

    let pointer = UnsafeMutablePointer<T>.alloc(1)
    data.getBytes(pointer, length: data.length)

    return pointer.move()
  }

  public func encode(var value: T) throws -> NSData {
    return withUnsafePointer(&value) { p in
      NSData(bytes: p, length: sizeofValue(value))
    }
  }
}
