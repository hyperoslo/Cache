import Foundation

public class Transformer<T> {
  let toData: (T) throws -> Data
  let fromData: (Data) throws -> T

  public init(toData: @escaping (T) throws -> Data, fromData: @escaping (Data) throws -> T) {
    self.toData = toData
    self.fromData = fromData
  }
}

extension Transformer {
  static func forData() -> Transformer<Data> {
    let toData: (Data) throws -> Data = { $0 }

    let fromData: (Data) throws -> Data = { $0 }

    return Transformer<Data>(toData: toData, fromData: fromData)
  }

  static func forImage() -> Transformer<Image> {
    let toData: (Image) throws -> Data = { image in
      return try image.cache_toData().unwrapOrThrow(error: StorageError.transformerFail)
    }

    let fromData: (Data) throws -> Image = { data in
      return try Image(data: data).unwrapOrThrow(error: StorageError.transformerFail)
    }

    return Transformer<Image>(toData: toData, fromData: fromData)
  }

  static func forCodable<U: Codable>(ofType: U) -> Transformer<U> {
    let toData: (U) throws -> Data = { object in
      let encoder = JSONEncoder()
      return try encoder.encode(object)
    }

    let fromData: (Data) throws -> U = { data in
      let decoder = JSONDecoder()
      return try decoder.decode(U.self, from: data)
    }

    return Transformer<U>(toData: toData, fromData: fromData)
  }
}
