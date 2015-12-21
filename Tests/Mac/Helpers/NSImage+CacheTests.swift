import Cocoa
@testable import Cache

extension NSImage {

  func isEqualToImage(image: NSImage) -> Bool {
    return data.isEqualToData(image.data)
  }

  var data: NSData {
    let representation = TIFFRepresentation!

    let imageFileType: NSBitmapImageFileType = hasAlpha
      ? .NSPNGFileType
      : .NSJPEGFileType

    return (NSBitmapImageRep(data: representation)?.representationUsingType(
      imageFileType, properties: [:]))!
  }
}
