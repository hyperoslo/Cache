import Foundation

public typealias JSONDictionary = [String: Any]

public struct JSONDictionaryWrapper: Codable {
  public let jsonDictionary: JSONDictionary

  public enum CodingKeys: String, CodingKey {
    case jsonDictionary
  }

  public init(jsonDictionary: JSONDictionary) {
    self.jsonDictionary = jsonDictionary
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let data = try container.decode(Data.self, forKey: CodingKeys.jsonDictionary)
    let object = try JSONSerialization.jsonObject(
      with: data,
      options: []
    )

    guard let jsonDictionary = object as? JSONDictionary else {
      throw StorageError.decodingFailed
    }

    self.jsonDictionary = jsonDictionary
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    let data = try JSONSerialization.data(
      withJSONObject: jsonDictionary,
      options: []
    )

    try container.encode(data, forKey: CodingKeys.jsonDictionary)
  }
}
