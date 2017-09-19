import Foundation

/// Deal with top level primitive. Use TypeWrapper as wrapper
/// Because we use `JSONEncoder` and `JSONDecoder`.
/// Avoid issue like "Top-level T encoded as number JSON fragment"
final class TypeWrapperStorage {
  let internalStorage: StorageAware

  init(storage: StorageAware) {
    self.internalStorage = storage
  }
}

extension TypeWrapperStorage: StorageAware {
  public func entry<T: Codable>(ofType type: T.Type, forKey key: String) throws -> Entry<T> {
    let wrapperEntry = try internalStorage.entry(ofType: TypeWrapper<T>.self, forKey: key)
    return Entry(object: wrapperEntry.object.object, expiry: wrapperEntry.expiry)
  }

  public func removeObject(forKey key: String) throws {
    try internalStorage.removeObject(forKey: key)
  }

  public func setObject<T: Codable>(_ object: T, forKey key: String,
                                    expiry: Expiry? = nil) throws {
    let wrapper = TypeWrapper<T>(object: object)
    try internalStorage.setObject(wrapper, forKey: key, expiry: expiry)
  }

  public func removeAll() throws {
    try internalStorage.removeAll()
  }

  public func removeExpiredObjects() throws {
    try internalStorage.removeExpiredObjects()
  }
}

/// Used to wrap Codable object
struct TypeWrapper<T: Codable>: Codable {
  enum CodingKeys: String, CodingKey {
    case object
  }

  let object: T

  init(object: T) {
    self.object = object
  }
}
