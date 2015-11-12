import Foundation

public enum EncodingError: ErrorType {
  case InvalidSize
}

public struct DefaultConverter<T>: CacheConverter {

  public typealias CacheType = T

  public func decode(data: NSData) throws -> CacheType {
    guard data.length == sizeof(CacheType) else {
      throw EncodingError.InvalidSize
    }

    let pointer = UnsafeMutablePointer<CacheType>.alloc(1)
    data.getBytes(pointer, length: data.length)

    return pointer.move()
  }

  public func encode(var value: CacheType) throws -> NSData {
    return withUnsafePointer(&value) { p in
      NSData(bytes: p, length: sizeofValue(value))
    }
  }
}