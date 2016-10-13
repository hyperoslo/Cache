import Foundation

/**
 Helper enum to work with JSON arrays and dictionaries
 */
public enum JSON {
  /// JSON array
  case array([Any])
  /// JSON dictionary
  case dictionary([String : Any])

  /// Converts value to AnyObject
  public var object: Any {
    var result: Any

    switch self {
    case .array(let object):
      result = object as Any
    case .dictionary(let object):
      result = object as Any
    }

    return result
  }
}
