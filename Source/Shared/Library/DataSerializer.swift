import Foundation

/// Convert to and from data
class DataSerializer {

  /// Convert object to data
  ///
  /// - Parameter object: The object to convert
  /// - Returns: Data
  /// - Throws: Encoder error if any
  static func serialize<T: Encodable>(object: T) throws -> Data {
    let encoder = JSONEncoder()
    return try encoder.encode(object)
  }

  /// Convert data to object
  ///
  /// - Parameter data: The data to convert
  /// - Returns: The object
  /// - Throws: Decoder error if any
  static func deserialize<T: Decodable>(data: Data) throws -> T {
    let decoder = JSONDecoder()
    return try decoder.decode(T.self, from: data)
  }
}
