import Foundation

public extension Storage2 {
  func supportData() -> Storage2<Data> {
    let storage = support(transformer: Transformer<Data>.forData())
    return storage
  }

  func supportImage() -> Storage2<Image> {
    let storage = support(transformer: Transformer<Image>.forImage())
    return storage
  }

  func supportCodable<U: Codable>(ofType: U.Type) -> Storage2<U> {
    let storage = support(transformer: Transformer<U>.forCodable(ofType: U.self))
    return storage
  }
}
