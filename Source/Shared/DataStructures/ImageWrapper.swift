import UIKit

struct ImageWrapper: Codable {
  let image: UIImage

  enum CodingKeys: String, CodingKey {
    case image
  }

  public init(image: UIImage) {
    self.image = image
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let data = try container.decode(Data.self, forKey: CodingKeys.image)
    guard let image = UIImage(data: data) else {
      throw CacheError.constructCodableObjectFailed
    }

    self.image = image
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    guard let data = image.hasAlpha
      ? UIImagePNGRepresentation(image)
      : UIImageJPEGRepresentation(image, 1.0) else {
        return
    }
    try container.encode(data)
  }
}
