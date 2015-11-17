import UIKit

// MARK: - Cachable

extension UIImage: Cachable {

  public typealias CacheType = UIImage

  public static func decode(data: NSData) -> CacheType? {
    let image = UIImage(data: data)
    return image
  }

  public func encode() -> NSData? {
    return hasAlpha
      ? UIImagePNGRepresentation(self)
      : UIImageJPEGRepresentation(self, 1.0)
  }
}

// MARK: - Helpers

extension UIImage {

  var hasAlpha: Bool {
    let result: Bool
    let alpha = CGImageGetAlphaInfo(CGImage)

    switch alpha {
    case .None, .NoneSkipFirst, .NoneSkipLast:
      result = false
    default:
      result = true
    }

    return result
  }
}
