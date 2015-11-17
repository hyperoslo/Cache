import UIKit

// MARK: - Cachable

extension UIImage: Cachable {

  public typealias CacheType = UIImage

  public static func decode(data: NSData) -> CacheType? {
    let image = UIImage(data: data)
    return image
  }

  public func encode() -> NSData? {
    return nil
  }
}
