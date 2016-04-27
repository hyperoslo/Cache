import Foundation

/**
 Encoding error type
 */
public enum EncodingError: ErrorType {
  case InvalidSize
}

/**
 You could use this NSData encoding and decoding implementation for any kind of objects,
 but do it on your own risk. With this approach decoding will not work if the NSData length
 doesn't match the type size. This can commonly happen if you try to read the data after
 updates in the type's structure, so there is a different-sized version of the same type.
 Also note that sizeof() and sizeofValue() may return different values on different devices.
 */
public struct DefaultCacheConverter<T> {

  /// Initialization
  public init() {}

  /**
   Creates an instance from NSData

   - Parameter data: Data to decode from
   */
  public func decode(data: NSData) throws -> T {
    guard data.length == sizeof(T) else {
      throw EncodingError.InvalidSize
    }

    let pointer = UnsafeMutablePointer<T>.alloc(1)
    data.getBytes(pointer, length: data.length)

    return pointer.move()
  }

  /**
   Encodes an instance to NSData
   */
  public func encode(value: T) throws -> NSData {
    var value = value
    return withUnsafePointer(&value) { p in
      NSData(bytes: p, length: sizeofValue(value))
    }
  }
}
