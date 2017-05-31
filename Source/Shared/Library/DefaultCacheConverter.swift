import Foundation

/**
 Encoding error type
 */
public enum EncodingError: Error {
  case invalidSize
}

/**
 You could use this NSData encoding and decoding implementation for any kind of objects,
 but do it on your own risk. With this approach decoding will not work if the NSData length
 doesn't match the type size. This can commonly happen if you try to read the data after
 updates in the type's structure, so there is a different-sized version of the same type.
 Also note that `size` and `size(ofValue:)` may return different values on different devices.
 */
public struct DefaultCacheConverter<T> {
  /// Initialization
  public init() {}

  /**
   Creates an instance from NSData
   - Parameter data: Data to decode from
   - Returns: A generic type or throws
   */
  public func decode(_ data: Data) throws -> T {
    guard data.count == MemoryLayout<T>.size else {
      throw EncodingError.invalidSize
    }

    let pointer = UnsafeMutablePointer<T>.allocate(capacity: 1)
    (data as NSData).getBytes(pointer, length: data.count)

    return pointer.move()
  }

  /**
   Encodes an instance to NSData
   - Parameter value: A generic value
   - Returns: A NSData or throws
   */
  public func encode(_ value: T) throws -> Data {
    var value = value
    return withUnsafePointer(to: &value) {
      $0.withMemoryRebound(to: UInt8.self, capacity: 1) { bytes in
        Data(bytes: bytes, count: MemoryLayout.size(ofValue: value))
      }
    }
  }
}
