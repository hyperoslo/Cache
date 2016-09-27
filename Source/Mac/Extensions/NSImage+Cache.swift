import Foundation
import Cocoa

// MARK: - Cachable

/**
 Implementation of Cachable protocol.
 */
extension NSImage: Cachable {

  public typealias CacheType = NSImage

  /**
   Creates UIImage from NSData

   - Parameter data: Data to decode from
   - Returns: Optional CacheType
   */
  public static func decode(_ data: Data) -> CacheType? {
    let image = NSImage(data: data)
    return image
  }

  /**
   Encodes UIImage to NSData
   - Returns: Optional NSData
   */
  public func encode() -> Data? {
    guard let data = tiffRepresentation else { return nil }

    let imageFileType: NSBitmapImageFileType = hasAlpha ? .PNG : .JPEG
    return NSBitmapImageRep(data: data)?.representation(using: imageFileType, properties: [:])
  }
}

// MARK: - Helpers

/**
 Helper UIImage extension.
 */
extension NSImage {

  /**
   Checks if image has alpha component
   */
  var hasAlpha: Bool {
    var imageRect: CGRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)

    guard let imageRef = cgImage(forProposedRect: &imageRect, context: nil, hints: nil) else {
      return false
    }

    let result: Bool
    let alpha = imageRef.alphaInfo

    switch alpha {
    case .none, .noneSkipFirst, .noneSkipLast:
      result = false
    default:
      result = true
    }

    return result
  }
}
