import UIKit

// MARK: - Cachable

extension UIImage: Cachable {

  public typealias CacheType = UIImage

  public static func decode(data: NSData) -> CacheType? {
    let image = UIImage(data: data)
    return image
  }

  public func encode() -> NSData? {
    let data = hasAlpha
      ? UIImagePNGRepresentation(self) : UIImageJPEGRepresentation(self, CGFloat(compressionQuality))
    return data
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
