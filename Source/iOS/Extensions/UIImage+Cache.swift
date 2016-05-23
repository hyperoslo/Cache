import UIKit

// MARK: - Cachable

/**
 Implementation of Cachable protocol.
 */
extension UIImage: Cachable {

  public typealias CacheType = UIImage

  /**
   Creates UIImage from NSData

   - Parameter data: Data to decode from
   - Returns: An optional share type
   */
  public static func decode(data: NSData) -> CacheType? {
    let image = UIImage(data: data)
    return image
  }

  /**
   Encodes UIImage to NSData

   - Returns: Optional NSData
   */
  public func encode() -> NSData? {
    return hasAlpha
      ? UIImagePNGRepresentation(self)
      : UIImageJPEGRepresentation(self, 1.0)
  }
}

// MARK: - Helpers

/**
 Helper UIImage extension.
 */
extension UIImage {

  /**
   Checks if image has alpha component
   */
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
