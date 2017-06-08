import Foundation

/// A wrapper around array of `Cachable` objects that performs data decoding and encoding.
public struct CacheArray<T: Cachable>: Cachable {
  /// Array of elements
  public let elements: [T]

  /**
   Creates an instance of `CacheArray`
   - Parameter elements: Array of `Cachable` elements
   */
  public init(elements: [T]) {
    self.elements = elements
  }

  /**
   Creates an instance from Data.
   - Parameter data: Data to decode from
   - Returns: An optional CacheType
   */
  public static func decode(_ data: Data) -> CacheArray<T>? {
    // Unarchive object as an array of data
    guard let dataArray = (NSKeyedUnarchiver.unarchiveObject(with: data) as? NSArray) as? [Data] else {
      return nil
    }

    do {
      // Decode data to element of `T` type.
      let elements = try dataArray.map ({ data -> T in
        guard let element = T.decode(data) as? T else {
          throw Error.decodingFailed
        }
        return element
      })
      return CacheArray(elements: elements)
    } catch {
      return nil
    }
  }

  /**
   Encodes an instance to Data.
   - Returns: Optional Data
   */
  public func encode() -> Data? {
    do {
      // Create an array of data to be able to archive as `NSArray`
      let dataArray = try elements.map ({ element -> Data in
        guard let data = element.encode() else {
          throw Error.encodingFailed
        }
        return data
      })
      return NSKeyedArchiver.archivedData(withRootObject: NSArray(array: dataArray))
    } catch {
      return nil
    }
  }
}

private enum Error: Swift.Error {
  case encodingFailed
  case decodingFailed
}
