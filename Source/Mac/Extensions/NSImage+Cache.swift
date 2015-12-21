import Foundation
import Cocoa

// MARK: - Cachable

extension NSImage: Cachable {

  public typealias CacheType = NSImage

  public static func decode(data: NSData) -> CacheType? {
    let image = NSImage(data: data)
    return image
  }

  public func encode() -> NSData? {
    guard let data = TIFFRepresentation else { return nil }

    let imageFileType: NSBitmapImageFileType = hasAlpha
      ? .NSPNGFileType
      : .NSJPEGFileType

    return NSBitmapImageRep(data: data)?.representationUsingType(imageFileType, properties: [:])
  }
}

// MARK: - Helpers

extension NSImage {

  var hasAlpha: Bool {
    var imageRect:CGRect = CGRectMake(0, 0, size.width, size.height)
    let imageRef = CGImageForProposedRect(&imageRect, context: nil, hints: nil)
    let result: Bool
    let alpha = CGImageGetAlphaInfo(imageRef)

    switch alpha {
    case .None, .NoneSkipFirst, .NoneSkipLast:
      result = false
    default:
      result = true
    }

    return result
  }
}
