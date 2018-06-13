import Foundation

public extension Storage2 {
  func supportImage() -> Storage2<Image> {
    let storage = support(transformer: Transformer.imageTransformer())
    return storage
  }

  func supportCodable() -> Storage2<Codable> {
    fatalError()
  }
}
