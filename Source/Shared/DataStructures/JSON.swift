import Foundation

/**
 Helper enum to work with JSON arrays and dictionaries.
 */
public enum JSON {
  /// JSON array
  case array([Any])
  /// JSON dictionary
  case dictionary([String : Any])

  /// Converts value to Any
  public var object: Any {
    switch self {
    case .array(let object):
      return object
    case .dictionary(let object):
      return object
    }
  }
}
