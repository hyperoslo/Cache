import Foundation

public class TransformerFactory {
  public static func forData() -> Transformer<Data> {
    let toData: (Data) throws -> Data = { $0 }

    let fromData: (Data) throws -> Data = { $0 }

    return Transformer<Data>(toData: toData, fromData: fromData)
  }

  #if os(iOS) || os(tvOS) || os(macOS)
  public static func forImage() -> Transformer<Image> {
    let toData: (Image) throws -> Data = { image in
      return try image.cache_toData().unwrapOrThrow(error: StorageError.transformerFail)
    }

    let fromData: (Data) throws -> Image = { data in
      return try Image(data: data).unwrapOrThrow(error: StorageError.transformerFail)
    }

    return Transformer<Image>(toData: toData, fromData: fromData)
  }
  #endif

  public static func forCodable<U: Codable>(ofType: U.Type) -> Transformer<U> {
    let toData: (U) throws -> Data = { object in
      let wrapper = TypeWrapper<U>(object: object)
      let encoder = JSONEncoder()
      return try encoder.encode(wrapper)
    }

    let fromData: (Data) throws -> U = { data in
      let decoder = JSONDecoder()
      return try decoder.decode(TypeWrapper<U>.self, from: data).object
    }

    return Transformer<U>(toData: toData, fromData: fromData)
  }
}
