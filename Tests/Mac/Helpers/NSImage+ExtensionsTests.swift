import Cocoa
@testable import Cache

extension NSImage {
  func isEqualToImage(_ image: NSImage) -> Bool {
    return data == image.data
  }

  var data: Data {
    let representation = tiffRepresentation!
    let imageFileType: NSBitmapImageRep.FileType = .png

    return NSBitmapImageRep(data: representation)!
      .representation(using: imageFileType, properties: [:])!
  }
}
