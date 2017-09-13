import UIKit

struct ImageWrapper: Codable {
  let image: Image

  enum CodingKeys: String, CodingKey {
    case image
  }

  public init(image: Image) {
    self.image = image
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let data = try container.decode(Data.self, forKey: CodingKeys.image)
    guard let image = Image(data: data) else {
      throw CacheError.decodingFailed
    }

    self.image = image
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    guard let data = image.hasAlpha
      ? UIImagePNGRepresentation(image)
      : UIImageJPEGRepresentation(image, 1.0) else {
        throw CacheError.encodingFailed
    }

    try container.encode(data, forKey: CodingKeys.image)
  }
}