import Foundation

public extension Storage {
  func supportData() -> Storage<Data> {
    let storage = support(transformer: Transformer<Data>.forData())
    return storage
  }

  func supportImage() -> Storage<Image> {
    let storage = support(transformer: Transformer<Image>.forImage())
    return storage
  }

  func supportCodable<U: Codable>(ofType: U.Type) -> Storage<U> {
    let storage = support(transformer: Transformer<U>.forCodable(ofType: U.self))
    return storage
  }
}
