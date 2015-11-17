import Foundation

// MARK: - Helpers

extension NSData {

  enum Format {
    case PNG, JPEG, GIF, Other
  }

  var format: Format {
    let pngBytes: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
    let jpgBytes: [UInt8] = [0xFF, 0xD8, 0xFF]
    let gifBytes: [UInt8] = [0x47, 0x49, 0x46]

    var buffer = [UInt8](count: 8, repeatedValue: 0)
    getBytes(&buffer, length: 8)

    if buffer == pngBytes {
      return .PNG
    } else if buffer[0...2] == jpgBytes[0...2] {
      return .JPEG
    } else if buffer[0...2] == gifBytes[0...2] {
      return .GIF
    }

    return .Other
  }
}
