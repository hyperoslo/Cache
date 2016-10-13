import Cocoa
@testable import Cache

extension NSImage {

  func isEqualToImage(image: NSImage) -> Bool {
    return data == image.data
  }

  var data: Data {
    let representation = tiffRepresentation!

    let imageFileType: NSBitmapImageFileType = hasAlpha ? .PNG : .JPEG

    return (NSBitmapImageRep(data: representation)?.representation(
      using: imageFileType,
      properties: [:]))!
  }
}
