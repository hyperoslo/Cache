import Cocoa
@testable import Cache

extension NSImage {

  func isEqualToImage(image: NSImage) -> Bool {
    return data.isEqualToData(image.data)
  }

  var data: NSData {
    let representation = TIFFRepresentation!

    #if swift(>=2.3)
    let imageFileType: NSBitmapImageFileType = hasAlpha
      ? .PNG
      : .JPEG
    #else
    let imageFileType: NSBitmapImageFileType = hasAlpha
      ? .NSPNGFileType
      : .NSJPEGFileType
    #endif

    return (NSBitmapImageRep(data: representation)?.representationUsingType(
      imageFileType, properties: [:]))!
  }
}
