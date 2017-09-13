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
    guard isPrimitive(type: T.self) else {
      return try internalStorage.entry(forKey: key) as Entry<T>
    }

    let wrapperEntry = try internalStorage.entry(forKey: key) as Entry<PrimitiveWrapper<T>>
    let primitiveEntry = Entry(object: wrapperEntry.object.value,
                               expiry: wrapperEntry.expiry)
    return primitiveEntry
  }

  public func removeObject(forKey key: String) throws {
    try internalStorage.removeObject(forKey: key)
  }

  public func setObject<T: Codable>(_ object: T, forKey key: String,
                                    expiry: Expiry? = nil) throws {
    guard isPrimitive(type: T.self) else {
      try internalStorage.setObject(object, forKey: key, expiry: expiry)
      return
    }

    let wrapper = PrimitiveWrapper(value: object)
    try internalStorage.setObject(wrapper, forKey: key, expiry: expiry)
  }

  public func removeAll() throws {
    try internalStorage.removeAll()
  }

  public func removeExpiredObjects() throws {
    try internalStorage.removeExpiredObjects()
  }
}

extension PrimitiveStorage {
  func isPrimitive<T>(type: T.Type) -> Bool {
    let primitives: [Any.Type] = [
      Bool.self, [Bool].self,
      String.self, [String].self,
      Int.self, [Int].self,
      Float.self, [Float].self,
      Double.self, [Double].self
    ]

    return primitives.contains(where: { $0.self == type.self })
  }
}
