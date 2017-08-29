import UIKit

// MARK: - Cachable

/**
 Implementation of Cachable protocol.
 */
extension UIImage: Cachable {
  public typealias CacheType = UIImage

  /**
   Creates UIImage from Data
   - Parameter data: Data to decode from
   - Returns: An optional share type
   */
  public static func decode(_ data: Data) -> CacheType? {
    let image = UIImage(data: data)
    return image
  }

  /**
   Encodes UIImage to Data
   - Returns: Optional Data
   */
  public func encode() -> Data? {
    return hasAlpha
      ? UIImagePNGRepresentation(self)
      : UIImageJPEGRepresentation(self, 1.0)
  }
}

// MARK: - Helpers

/**
 Helper UIImage extension.
 */
private extension UIImage {
  /**
   Checks if image has alpha component
   */
  var hasAlpha: Bool {
    let result: Bool

    guard let alpha = cgImage?.alphaInfo else {
      return false
    }

    switch alpha {
    case .none, .noneSkipFirst, .noneSkipLast:
      result = false
    default:
      result = true
    }

    return result
  }
}
