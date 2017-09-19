import Foundation

/// Convert json string, dictionary, data to Codable objects
public class ObjectConverter {
  /// Convert json string to Codable object
  ///
  /// - Parameters:
  ///   - string: Json string.
  ///   - type: Type information.
  /// - Returns: Codable object.
  /// - Throws: Error if failed.
  static func convert<T: Codable>(_ string: String, to type: T.Type) throws -> T {
    guard let data = string.data(using: .utf8) else {
      throw StorageError.decodingFailed
    }

    return try convert(data, to: type.self)
  }

  /// Convert json dictionary to Codable object
  ///
  /// - Parameters:
  ///   - json: Json dictionary.
  ///   - type: Type information.
  /// - Returns: Codable object
  /// - Throws: Error if failed
  static func convert<T: Codable>(_ json: [String: Any], to type: T.Type) throws -> T {
    let data = try JSONSerialization.data(withJSONObject: json, options: [])
    return try convert(data, to: type)
  }

  /// Convert json data to Codable object
  ///
  /// - Parameters:
  ///   - json: Json dictionary.
  ///   - type: Type information.
  /// - Returns: Codable object
  /// - Throws: Error if failed
  static func convert<T: Codable>(_ data: Data, to type: T.Type) throws -> T {
    return try JSONDecoder().decode(T.self, from: data)
  }
}
