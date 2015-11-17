import Foundation

public enum JSON {
  case Array([AnyObject])
  case Dictionary([String : AnyObject])

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
