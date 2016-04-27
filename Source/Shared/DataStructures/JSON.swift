import Foundation

/**
 Helper enum to work with JSON arrays and dictionaries
 */
public enum JSON {
  /// JSON array
  case Array([AnyObject])
  /// JSON dictionary
  case Dictionary([String : AnyObject])

  /// Converts value to AnyObject
  public var object: AnyObject {
    var result: AnyObject

    switch self {
    case .Array(let object):
      result = object
    case .Dictionary(let object):
      result = object
    }

    return result
  }
}
