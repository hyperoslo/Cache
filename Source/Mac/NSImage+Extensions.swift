import AppKit

/// Helper UIImage extension.
extension NSImage {
  /// Checks if image has alpha component
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

  /// Convert to data
  func cache_toData() -> Data? {
    guard let data = tiffRepresentation else {
      return nil
    }

    let imageFileType: NSBitmapImageRep.FileType = hasAlpha ? .png : .jpeg
    return NSBitmapImageRep(data: data)?
      .representation(using: imageFileType, properties: [:])
  }
}
