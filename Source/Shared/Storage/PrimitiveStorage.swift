import Foundation
import SwiftHash

/// Allow storing primitive and image
final class PrimitiveStorage {
  let internalStorage: StorageAware

  init(storage: StorageAware) {
    self.internalStorage = storage
  }
}

extension PrimitiveStorage: StorageAware {
  public func entry<T: Codable>(forKey key: String) throws -> Entry<T> {
    do {
      return try internalStorage.entry(forKey: key) as Entry<T>
    } catch let error as Swift.DecodingError {
      // Expected to decode T but found a dictionary instead.
      switch error {
      case .typeMismatch(_, let context) where context.codingPath.isEmpty:
        let wrapperEntry = try internalStorage.entry(forKey: key) as Entry<PrimitiveWrapper<T>>
        let primitiveEntry = Entry(object: wrapperEntry.object.value,
                                   expiry: wrapperEntry.expiry)
        return primitiveEntry
      default:
        throw StorageError.typeNotMatch
      }
    } catch {
      throw StorageError.typeNotMatch
    }
  }

  public func removeObject(forKey key: String) throws {
    try internalStorage.removeObject(forKey: key)
  }

  public func setObject<T: Codable>(_ object: T, forKey key: String,
                                    expiry: Expiry? = nil) throws {

    do {
      try internalStorage.setObject(object, forKey: key, expiry: expiry)
    } catch let error as Swift.EncodingError {
      // Top-level T encoded as number JSON fragment
      switch error {
      case .invalidValue(_, let context) where context.codingPath.isEmpty:
        let wrapper = PrimitiveWrapper<T>(value: object)
        try internalStorage.setObject(wrapper, forKey: key, expiry: expiry)
      default:
        break
      }
    }
  }

  public func removeAll() throws {
    try internalStorage.removeAll()
  }

  public func removeExpiredObjects() throws {
    try internalStorage.removeExpiredObjects()
  }
}
