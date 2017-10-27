import Foundation

public typealias JSONArray = [JSONDictionary]

public struct JSONArrayWrapper: Codable {
  public let jsonArray: JSONArray

  public enum CodingKeys: String, CodingKey {
    case jsonArray
  }

  public init(jsonArray: JSONArray) {
    self.jsonArray = jsonArray
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let data = try container.decode(Data.self, forKey: CodingKeys.jsonArray)
    let object = try JSONSerialization.jsonObject(
      with: data,
      options: []
    )

    guard let jsonArray = object as? JSONArray else {
      throw StorageError.decodingFailed
    }

    self.jsonArray = jsonArray
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    let data = try JSONSerialization.data(
      withJSONObject: jsonArray,
      options: []
    )

    try container.encode(data, forKey: CodingKeys.jsonArray)
  }
}
