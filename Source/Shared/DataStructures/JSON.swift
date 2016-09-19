import Foundation

/**
 Helper enum to work with JSON arrays and dictionaries
 */
public enum JSON {
  /// JSON array
  case array([AnyObject])
  /// JSON dictionary
  case dictionary([String : AnyObject])

  /// Converts value to AnyObject
  public var object: AnyObject {
    var result: AnyObject

    switch self {
    case .array(let object):
      result = object as AnyObject
    case .dictionary(let object):
      result = object as AnyObject
    }

    return result
  }
}
