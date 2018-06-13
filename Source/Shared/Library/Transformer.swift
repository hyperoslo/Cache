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
  static func imageTransformer() -> Transformer<Image> {
    let toData: (Image) throws -> Data = { image in
      return try image.cache_toData().unwrapOrThrow(error: StorageError.transformerFail)
    }

    let fromData: (Data) throws -> Image = { data in
      return try Image(data: data).unwrapOrThrow(error: StorageError.transformerFail)
    }

    return Transformer<Image>(toData: toData, fromData: fromData)
  }
}
