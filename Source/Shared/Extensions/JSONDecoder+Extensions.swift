import Foundation

/// Convert json string, dictionary, data to Codable objects
public extension JSONDecoder {
  /// Convert json string to Codable object
  ///
  /// - Parameters:
  ///   - string: Json string.
  ///   - type: Type information.
  /// - Returns: Codable object.
  /// - Throws: Error if failed.
  static func decode<T: Codable>(_ string: String, to type: T.Type) throws -> T {
    guard let data = string.data(using: .utf8) else {
      throw StorageError.decodingFailed
    }

    return try decode(data, to: type.self)
  }

  /// Convert json dictionary to Codable object
  ///
  /// - Parameters:
  ///   - json: Json dictionary.
  ///   - type: Type information.
  /// - Returns: Codable object
  /// - Throws: Error if failed
  static func decode<T: Codable>(_ json: [String: Any], to type: T.Type) throws -> T {
    let data = try JSONSerialization.data(withJSONObject: json, options: [])
    return try decode(data, to: type)
  }

  /// Convert json data to Codable object
  ///
  /// - Parameters:
  ///   - json: Json dictionary.
  ///   - type: Type information.
  /// - Returns: Codable object
  /// - Throws: Error if failed
  static func decode<T: Codable>(_ data: Data, to type: T.Type) throws -> T {
    return try JSONDecoder().decode(T.self, from: data)
  }
}
