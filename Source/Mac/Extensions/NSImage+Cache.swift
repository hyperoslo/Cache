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
  public static func decode(data: NSData) -> CacheType? {
    let image = NSImage(data: data)
    return image
  }

  /**
   Encodes UIImage to NSData
   - Returns: Optional NSData
   */
  public func encode() -> NSData? {
    guard let data = TIFFRepresentation else { return nil }

    #if swift(>=2.3)
    let imageFileType: NSBitmapImageFileType = hasAlpha
      ? .PNG
      : .JPEG
    #else
    let imageFileType: NSBitmapImageFileType = hasAlpha
      ? .NSPNGFileType
      : .NSJPEGFileType
    #endif
        
    return NSBitmapImageRep(data: data)?.representationUsingType(imageFileType, properties: [:])
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
    let imageRef = CGImageForProposedRect(&imageRect, context: nil, hints: nil)
    let result: Bool
    
    #if swift(>=2.3)
    let alpha: CGImageAlphaInfo
    if let image = imageRef {
        alpha = CGImageGetAlphaInfo(image)
    } else {
        alpha = .None
    }
    #else
    let alpha = CGImageGetAlphaInfo(imageRef)
    #endif

    switch alpha {
    case .None, .NoneSkipFirst, .NoneSkipLast:
      result = false
    default:
      result = true
    }

    return result
  }
}
